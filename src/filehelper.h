#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>

class FileHelper : public QObject
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = nullptr);

    Q_INVOKABLE QString backupPath() const;
    Q_INVOKABLE bool writeBackup(const QString &text) const;
    Q_INVOKABLE QString readBackup() const;
};

#endif
