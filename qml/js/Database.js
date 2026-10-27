.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

var SCHEMA_VERSION = 3

function db() {
    return Sql.LocalStorage.openDatabaseSync(
                "SailCycle",
                "1.0",
                "Sail Cycle local data",
                2000000)
}

function hasColumn(tx, columnName) {
    var result = tx.executeSql("PRAGMA table_info(records)")
    for (var i = 0; i < result.rows.length; i++) {
        if (result.rows.item(i).name === columnName)
            return true
    }
    return false
}

function init() {
    db().transaction(function(tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS settings ("
                    + "key TEXT UNIQUE, "
                    + "value TEXT)")

        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS records ("
                    + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    + "recordDate TEXT NOT NULL, "
                    + "recordType TEXT NOT NULL, "
                    + "flow TEXT NOT NULL DEFAULT 'none', "
                    + "observations TEXT NOT NULL DEFAULT '', "
                    + "notes TEXT NOT NULL DEFAULT '', "
                    + "createdAt TEXT NOT NULL DEFAULT '', "
                    + "updatedAt TEXT NOT NULL DEFAULT '')")

        if (!hasColumn(tx, "observations"))
            tx.executeSql("ALTER TABLE records ADD COLUMN observations TEXT NOT NULL DEFAULT ''")
        if (!hasColumn(tx, "notes"))
            tx.executeSql("ALTER TABLE records ADD COLUMN notes TEXT NOT NULL DEFAULT ''")
        if (!hasColumn(tx, "createdAt"))
            tx.executeSql("ALTER TABLE records ADD COLUMN createdAt TEXT NOT NULL DEFAULT ''")
        if (!hasColumn(tx, "updatedAt"))
            tx.executeSql("ALTER TABLE records ADD COLUMN updatedAt TEXT NOT NULL DEFAULT ''")
        if (!hasColumn(tx, "wellbeingScore"))
            tx.executeSql("ALTER TABLE records ADD COLUMN wellbeingScore INTEGER")
        if (!hasColumn(tx, "painScore"))
            tx.executeSql("ALTER TABLE records ADD COLUMN painScore INTEGER")
        if (!hasColumn(tx, "extraData"))
            tx.executeSql("ALTER TABLE records ADD COLUMN extraData TEXT NOT NULL DEFAULT '{}'")

        tx.executeSql(
                    "CREATE UNIQUE INDEX IF NOT EXISTS record_date_type "
                    + "ON records(recordDate, recordType)")
    })
}

function isoDate(value) {
    var month = value.getMonth() + 1
    var day = value.getDate()
    return value.getFullYear()
            + "-" + (month < 10 ? "0" : "") + month
            + "-" + (day < 10 ? "0" : "") + day
}

function parseDate(value) {
    if (!value)
        return null
    var parts = value.split("-")
    if (parts.length !== 3)
        return null
    return new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]))
}

function addDays(value, amount) {
    return new Date(value.getFullYear(), value.getMonth(), value.getDate() + amount)
}

function dayDifference(first, second) {
    var firstDate = new Date(first.getFullYear(), first.getMonth(), first.getDate())
    var secondDate = new Date(second.getFullYear(), second.getMonth(), second.getDate())
    return Math.floor((secondDate.getTime() - firstDate.getTime()) / 86400000)
}

function setting(key, fallbackValue) {
    init()
    var value = fallbackValue
    db().readTransaction(function(tx) {
        var result = tx.executeSql(
                    "SELECT value FROM settings WHERE key=?",
                    [key])
        if (result.rows.length)
            value = result.rows.item(0).value
    })
    return value
}

function saveSetting(key, value) {
    init()
    db().transaction(function(tx) {
        tx.executeSql(
                    "INSERT OR REPLACE INTO settings(key,value) VALUES(?,?)",
                    [key, String(value)])
    })
}

function records() {
    init()
    var values = []
    db().readTransaction(function(tx) {
        var result = tx.executeSql(
                    "SELECT id,recordDate,recordType,flow,observations,notes,"
                    + "createdAt,updatedAt,wellbeingScore,painScore,extraData "
                    + "FROM records ORDER BY recordDate,id")
        for (var i = 0; i < result.rows.length; i++)
            values.push(result.rows.item(i))
    })
    return values
}

function recordForDate(dateText) {
    init()
    var value = null
    db().readTransaction(function(tx) {
        var result = tx.executeSql(
                    "SELECT id,recordDate,recordType,flow,observations,notes,"
                    + "wellbeingScore,painScore,extraData "
                    + "FROM records WHERE recordDate=? ORDER BY id LIMIT 1",
                    [dateText])
        if (result.rows.length)
            value = result.rows.item(0)
    })
    return value
}

function validWellbeingScore(value) {
    var number = parseInt(value)
    return number >= 1 && number <= 5 ? number : null
}

function validPainScore(value) {
    var number = parseInt(value)
    return number >= 0 && number <= 5 ? number : null
}

function normalizedExtraData(value) {
    if (!value)
        return "{}"
    try {
        var objectValue = typeof value === "string" ? JSON.parse(value) : value
        return JSON.stringify(objectValue || {})
    } catch (error) {
        return "{}"
    }
}

function saveRecord(id, dateText, recordType, flow, observations, notes,
                    wellbeingScore, painScore, extraData) {
    init()
    var now = new Date().toISOString()
    var wellbeing = validWellbeingScore(wellbeingScore)
    var pain = validPainScore(painScore)
    var extra = normalizedExtraData(extraData)

    db().transaction(function(tx) {
        if (id >= 0) {
            tx.executeSql(
                        "UPDATE records SET recordDate=?,recordType=?,flow=?,"
                        + "observations=?,notes=?,wellbeingScore=?,painScore=?,"
                        + "extraData=?,updatedAt=? WHERE id=?",
                        [dateText, recordType, flow || "none",
                         observations || "", notes || "", wellbeing, pain,
                         extra, now, id])
        } else {
            tx.executeSql(
                        "INSERT OR REPLACE INTO records("
                        + "recordDate,recordType,flow,observations,notes,"
                        + "wellbeingScore,painScore,extraData,createdAt,updatedAt) "
                        + "VALUES(?,?,?,?,?,?,?,?,?,?)",
                        [dateText, recordType, flow || "none",
                         observations || "", notes || "", wellbeing, pain,
                         extra, now, now])
        }
    })
}

function deleteRecord(id) {
    init()
    db().transaction(function(tx) {
        tx.executeSql("DELETE FROM records WHERE id=?", [id])
    })
}

function periodStarts() {
    var values = []
    var allRecords = records()
    for (var i = 0; i < allRecords.length; i++) {
        if (allRecords[i].recordType === "periodStart") {
            var dateValue = parseDate(allRecords[i].recordDate)
            if (dateValue)
                values.push(dateValue)
        }
    }
    return values
}

function cycleIntervals() {
    var starts = periodStarts()
    var intervals = []
    for (var i = 1; i < starts.length; i++) {
        var interval = dayDifference(starts[i - 1], starts[i])
        if (interval >= 15 && interval <= 60)
            intervals.push(interval)
    }
    return intervals
}

function average(values) {
    if (!values || !values.length)
        return 0
    var sum = 0
    for (var i = 0; i < values.length; i++)
        sum += values[i]
    return Math.round(sum / values.length)
}

function prediction() {
    var starts = periodStarts()
    var manualLength = parseInt(setting("cycleLength", "28"))
    var periodLength = parseInt(setting("periodLength", "5"))
    var method = setting("predictionMethod", "recent3")
    var intervals = cycleIntervals()
    var usedIntervals = intervals.slice(0)

    if (method === "recent3" && usedIntervals.length > 3)
        usedIntervals = usedIntervals.slice(-3)

    var cycleLength = manualLength
    var basis = "Manual setting"

    if (method !== "manual" && usedIntervals.length) {
        cycleLength = average(usedIntervals)
        basis = method === "recent3"
                ? "Recent cycle average"
                : "All-cycle average"
    } else if (method !== "manual") {
        basis = "Manual fallback"
    }

    if (!starts.length) {
        return {
            available: false,
            cycleLength: cycleLength,
            periodLength: periodLength,
            basis: basis,
            historyCount: intervals.length
        }
    }

    var latest = starts[starts.length - 1]
    var next = addDays(latest, cycleLength)
    return {
        available: true,
        latest: latest,
        next: next,
        end: addDays(next, periodLength - 1),
        cycleLength: cycleLength,
        periodLength: periodLength,
        basis: basis,
        historyCount: intervals.length,
        cycleDay: dayDifference(latest, new Date()) + 1,
        daysToNext: dayDifference(new Date(), next)
    }
}

function validateRecord(id, dateText, recordType, flow, notes) {
    if (dateText > isoDate(new Date())) {
        return {
            valid: false,
            message: "Recorded information cannot be dated in the future."
        }
    }

    if (recordType === "periodEnd") {
        var starts = periodStarts()
        if (!starts.length) {
            return {
                valid: false,
                message: "Record a period start before recording the end."
            }
        }

        var selectedDate = parseDate(dateText)
        var lastStart = starts[starts.length - 1]
        var duration = dayDifference(lastStart, selectedDate) + 1

        if (duration < 1) {
            return {
                valid: false,
                message: "The period end cannot be before its start."
            }
        }
        if (duration > 14 && (!notes || notes.trim().length < 3)) {
            return {
                valid: false,
                message: "This period is longer than 14 days. Check the date or add a note."
            }
        }
    }

    if (recordType === "periodStart") {
        var periodStartValues = periodStarts()
        if (periodStartValues.length) {
            var newStart = parseDate(dateText)
            var lastRecordedStart = periodStartValues[periodStartValues.length - 1]
            var interval = Math.abs(dayDifference(lastRecordedStart, newStart))
            if ((interval < 15 || interval > 60)
                    && (!notes || notes.trim().length < 3)) {
                return {
                    valid: false,
                    message: "The cycle interval is " + interval
                             + " days. Check the date or add a note explaining the unusual interval."
                }
            }
        }
    }

    return { valid: true, message: "" }
}

function backupObject() {
    init()
    var settingsObject = {}
    db().readTransaction(function(tx) {
        var result = tx.executeSql("SELECT key,value FROM settings")
        for (var i = 0; i < result.rows.length; i++)
            settingsObject[result.rows.item(i).key] = result.rows.item(i).value
    })
    return {
        format: "SailCycleBackup",
        version: 3,
        exportedAt: new Date().toISOString(),
        settings: settingsObject,
        records: records()
    }
}

function importBackup(text) {
    init()
    var backup = JSON.parse(text)
    if (!backup || backup.format !== "SailCycleBackup")
        throw new Error("Unsupported backup file")
    if (!backup.records || !(backup.records instanceof Array))
        throw new Error("Backup records are missing")

    db().transaction(function(tx) {
        tx.executeSql("DELETE FROM records")
        tx.executeSql("DELETE FROM settings")

        var settingsObject = backup.settings || {}
        for (var key in settingsObject) {
            if (settingsObject.hasOwnProperty(key)) {
                tx.executeSql(
                            "INSERT OR REPLACE INTO settings(key,value) VALUES(?,?)",
                            [key, String(settingsObject[key])])
            }
        }

        for (var i = 0; i < backup.records.length; i++) {
            var record = backup.records[i]
            tx.executeSql(
                        "INSERT INTO records("
                        + "recordDate,recordType,flow,observations,notes,"
                        + "wellbeingScore,painScore,extraData,createdAt,updatedAt) "
                        + "VALUES(?,?,?,?,?,?,?,?,?,?)",
                        [record.recordDate,
                         record.recordType,
                         record.flow || "none",
                         record.observations || "",
                         record.notes || "",
                         record.wellbeingScore === undefined ? null : record.wellbeingScore,
                         record.painScore === undefined ? null : record.painScore,
                         normalizedExtraData(record.extraData),
                         record.createdAt || "",
                         record.updatedAt || ""])
        }
    })
}

function latestRecordedPeriodEndAfter(startDateText) {
    init()
    var resultDate = ""
    db().readTransaction(function(tx) {
        var result = tx.executeSql(
                    "SELECT recordDate FROM records "
                    + "WHERE recordType='periodEnd' AND recordDate>=? "
                    + "ORDER BY recordDate ASC LIMIT 1",
                    [startDateText])
        if (result.rows.length)
            resultDate = result.rows.item(0).recordDate
    })
    return resultDate
}

function dashboardData() {
    init()
    var allRecords = records()
    var estimate = prediction()
    var recordedDays = {}
    var currentEstimatedDays = {}
    var nextEstimatedDays = {}
    var recordedEndDays = {}
    var estimatedEndDays = {}
    var savedEntries = {}
    var currentEstimatedEnd = null
    var recordedCurrentEnd = ""

    for (var i = 0; i < allRecords.length; i++) {
        var record = allRecords[i]
        var hasFlow = record.flow
                && record.flow !== "none"
                && record.flow !== ""
        savedEntries[record.recordDate] = true

        if (record.recordType === "periodStart" || hasFlow)
            recordedDays[record.recordDate] = true

        if (record.recordType === "periodEnd") {
            recordedDays[record.recordDate] = true
            recordedEndDays[record.recordDate] = true
        }
    }

    if (estimate.available) {
        var latestText = isoDate(estimate.latest)
        recordedCurrentEnd = latestRecordedPeriodEndAfter(latestText)
        currentEstimatedEnd = addDays(
                    estimate.latest,
                    estimate.periodLength - 1)

        if (!recordedCurrentEnd
                && setting("showCurrentEstimate", "true") === "true") {
            for (var currentDay = 1;
                 currentDay < estimate.periodLength;
                 currentDay++) {
                currentEstimatedDays[
                            isoDate(addDays(estimate.latest, currentDay))] = true
            }
            estimatedEndDays[isoDate(currentEstimatedEnd)] = true
        }

        if (setting("predictionsEnabled", "true") === "true"
                && setting("showNextEstimate", "true") === "true") {
            for (var nextDay = 0;
                 nextDay < estimate.periodLength;
                 nextDay++) {
                nextEstimatedDays[
                            isoDate(addDays(estimate.next, nextDay))] = true
            }
            estimatedEndDays[isoDate(estimate.end)] = true
        }
    }

    return {
        records: allRecords,
        recordCount: allRecords.length,
        prediction: estimate,
        recordedDays: recordedDays,
        currentEstimatedDays: currentEstimatedDays,
        nextEstimatedDays: nextEstimatedDays,
        recordedEndDays: recordedEndDays,
        estimatedEndDays: estimatedEndDays,
        savedEntries: savedEntries,
        currentEstimatedEnd: currentEstimatedEnd,
        recordedCurrentEnd: recordedCurrentEnd,
        weekViewEnabled: setting("weekViewEnabled", "false") === "true",
        showWeekNumbers: setting("showWeekNumbers", "false") === "true",
        showEndColors: setting("showEndColors", "true") === "true",
        showEntryDots: setting("showEntryDots", "true") === "true",
        showLegend: setting("showLegend", "true") === "true"
    }
}

function scoreStatistics(fieldName, minimumScore, maximumScore,
                         startText, endText) {
    init()
    var counts = []
    for (var score = minimumScore; score <= maximumScore; score++)
        counts.push(0)

    var total = 0
    var sum = 0
    var daily = []
    var sql = "SELECT recordDate," + fieldName
            + " AS score FROM records WHERE " + fieldName
            + " IS NOT NULL"
    var argumentsArray = []

    if (startText && endText) {
        sql += " AND recordDate>=? AND recordDate<=?"
        argumentsArray.push(startText)
        argumentsArray.push(endText)
    }
    sql += " ORDER BY recordDate ASC"

    db().readTransaction(function(tx) {
        var result = tx.executeSql(sql, argumentsArray)
        for (var i = 0; i < result.rows.length; i++) {
            var value = parseInt(result.rows.item(i).score)
            if (value >= minimumScore && value <= maximumScore) {
                counts[value - minimumScore]++
                total++
                sum += value
                daily.push({
                    date: result.rows.item(i).recordDate,
                    score: value
                })
            }
        }
    })

    return {
        counts: counts,
        total: total,
        average: total ? Math.round(sum * 10 / total) / 10 : 0,
        daily: daily
    }
}

function wellbeingStatistics(startText, endText) {
    return scoreStatistics(
                "wellbeingScore", 1, 5, startText, endText)
}

function painStatistics(startText, endText) {
    return scoreStatistics(
                "painScore", 0, 5, startText, endText)
}

function statisticsData() {
    var intervals = cycleIntervals()
    var estimate = prediction()
    var shortest = intervals.length
            ? Math.min.apply(Math, intervals) : 0
    var longest = intervals.length
            ? Math.max.apply(Math, intervals) : 0

    return {
        intervals: intervals,
        periodStartCount: periodStarts().length,
        completedCycleCount: intervals.length,
        averageCycleLength: average(intervals),
        shortestCycleLength: shortest,
        longestCycleLength: longest,
        variation: intervals.length ? longest - shortest : 0,
        prediction: estimate,
        wellbeing: wellbeingStatistics(),
        pain: painStatistics()
    }
}

function coverData() {
    return {
        prediction: prediction(),
        showDetails: setting("coverDetailsEnabled", "false") === "true"
    }
}

function retentionMonths() {
    var mode = setting("retentionMode", "forever")
    return mode === "forever" ? 0 : parseInt(mode)
}

function expiredRecordCount() {
    var months = retentionMonths()
    if (!months)
        return 0

    var cutoff = new Date()
    cutoff.setMonth(cutoff.getMonth() - months)
    var count = 0

    db().readTransaction(function(tx) {
        var result = tx.executeSql(
                    "SELECT COUNT(*) AS count FROM records WHERE recordDate < ?",
                    [isoDate(cutoff)])
        count = result.rows.item(0).count
    })
    return count
}

function removeExpiredRecords() {
    init()
    var months = retentionMonths()
    if (!months)
        return 0

    var cutoff = new Date()
    cutoff.setMonth(cutoff.getMonth() - months)
    var removed = expiredRecordCount()

    db().transaction(function(tx) {
        tx.executeSql(
                    "DELETE FROM records WHERE recordDate < ?",
                    [isoDate(cutoff)])
    })
    return removed
}

function deleteAllRecords() {
    init()
    db().transaction(function(tx) {
        tx.executeSql("DELETE FROM records")
    })
}

function resetAllData() {
    init()
    db().transaction(function(tx) {
        tx.executeSql("DELETE FROM records")
        tx.executeSql("DELETE FROM settings")
    })
}

function recordsBetween(startText, endText) {
    init()
    var values = []
    db().readTransaction(function(tx) {
        var result = tx.executeSql(
                    "SELECT * FROM records "
                    + "WHERE recordDate>=? AND recordDate<=? "
                    + "ORDER BY recordDate,id",
                    [startText, endText])
        for (var i = 0; i < result.rows.length; i++)
            values.push(result.rows.item(i))
    })
    return values
}

function parseExtraData(value) {
    try {
        return JSON.parse(value || "{}")
    } catch (error) {
        return {}
    }
}

function rangeStatistics(startText, endText) {
    if (!startText || !endText || startText > endText)
        throw new Error("Invalid statistics date range")

    var list = recordsBetween(startText, endText)
    var wellbeing = [0, 0, 0, 0, 0]
    var pain = [0, 0, 0, 0, 0, 0]
    var flow = { spotting: 0, light: 0, medium: 0, heavy: 0 }
    var symptoms = {}
    var totals = {
        wellbeing: 0,
        pain: 0,
        wellbeingSum: 0,
        painSum: 0,
        energy: 0,
        energySum: 0,
        sleep: 0,
        sleepSum: 0,
        activityImpact: 0,
        bleedingImpact: 0,
        outsideBleeding: 0,
        largeClots: 0,
        sleepDisturbed: 0,
        entryDays: 0
    }
    var uniqueEntryDates = {}

    for (var i = 0; i < list.length; i++) {
        var record = list[i]
        uniqueEntryDates[record.recordDate] = true

        var wellbeingValue = parseInt(record.wellbeingScore)
        var painValue = parseInt(record.painScore)

        if (wellbeingValue >= 1 && wellbeingValue <= 5) {
            wellbeing[wellbeingValue - 1]++
            totals.wellbeing++
            totals.wellbeingSum += wellbeingValue
        }
        if (painValue >= 0 && painValue <= 5) {
            pain[painValue]++
            totals.pain++
            totals.painSum += painValue
        }
        if (flow[record.flow] !== undefined)
            flow[record.flow]++

        var observations = (record.observations || "").split(",")
        for (var j = 0; j < observations.length; j++) {
            var observation = observations[j].trim()
            if (observation)
                symptoms[observation] = (symptoms[observation] || 0) + 1
        }

        var extra = parseExtraData(record.extraData)
        var energy = parseInt(extra.energyScore)
        var sleep = parseInt(extra.sleepQuality)
        if (energy >= 1 && energy <= 5) {
            totals.energy++
            totals.energySum += energy
        }
        if (sleep >= 1 && sleep <= 5) {
            totals.sleep++
            totals.sleepSum += sleep
        }
        if (parseInt(extra.painImpact) >= 2)
            totals.activityImpact++
        if (parseInt(extra.bleedingImpact) >= 2)
            totals.bleedingImpact++
        if (parseInt(extra.outsideBleeding) > 1)
            totals.outsideBleeding++
        if (parseInt(extra.largeClots) === 1)
            totals.largeClots++
        if (parseInt(extra.sleepImpact) >= 2)
            totals.sleepDisturbed++
    }

    for (var dateKey in uniqueEntryDates) {
        if (uniqueEntryDates.hasOwnProperty(dateKey))
            totals.entryDays++
    }

    return {
        start: startText,
        end: endText,
        records: list,
        wellbeingCounts: wellbeing,
        painCounts: pain,
        flowCounts: flow,
        symptomCounts: symptoms,
        totals: totals,
        wellbeingAverage: totals.wellbeing
                ? Math.round(totals.wellbeingSum * 10 / totals.wellbeing) / 10
                : 0,
        painAverage: totals.pain
                ? Math.round(totals.painSum * 10 / totals.pain) / 10
                : 0,
        energyAverage: totals.energy
                ? Math.round(totals.energySum * 10 / totals.energy) / 10
                : 0,
        sleepAverage: totals.sleep
                ? Math.round(totals.sleepSum * 10 / totals.sleep) / 10
                : 0
    }
}
