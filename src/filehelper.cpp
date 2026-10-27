#include "filehelper.h"

#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QTextStream>

FileHelper::FileHelper(QObject *parent) : QObject(parent)
{
}

QString FileHelper::backupPath() const
{
    QString directory = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    if (directory.isEmpty())
        directory = QDir::homePath();
    QDir().mkpath(directory);
    return QDir(directory).filePath(QStringLiteral("SailCycle-backup.json"));
}

bool FileHelper::writeBackup(const QString &text) const
{
    QFile file(backupPath());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
        return false;
    QTextStream stream(&file);
    stream.setCodec("UTF-8");
    stream << text;
    return true;
}

QString FileHelper::readBackup() const
{
    QFile file(backupPath());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();
    QTextStream stream(&file);
    stream.setCodec("UTF-8");
    return stream.readAll();
}
