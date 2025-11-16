#ifndef ALARMRECEIVER_H
#define ALARMRECEIVER_H

#include <QObject>
#include <QRegularExpression>

class SerialBridge;

/**
 * @brief AlarmReceiver
 * Listens to text lines from SerialBridge and classifies them as error/warning/success.
 */
class AlarmReceiver : public QObject {
    Q_OBJECT
public:
    /// Construct an AlarmReceiver bound to a (non-owning) SerialBridge pointer.
    explicit AlarmReceiver(SerialBridge* bridge, QObject* parent = nullptr);

signals:
    // -----------------------
    // Classified message signals (UI can bind to these)
    // -----------------------

    /// Emitted when a received line is classified as an error.
    void rxError(const QString& line);

    /// Emitted when a received line is classified as a warning.
    void rxWarning(const QString& line);

    /// Emitted when a received line is classified as a success/OK.
    void rxSuccess(const QString& line);

public slots:
    /// Slot to handle each received line from SerialBridge and trigger classification.
    void onLineReceived(const QString& line);

private:
    /// Apply classification regexes and emit the first matching signal.
    void classifyAndEmit(const QString& line);

    // -----------------------
    // Regex patterns used to detect severity keywords
    // -----------------------

    /// Error keywords (e.g. "error", "failure", "failed", "fault").
    QRegularExpression m_reErr{
        R"(\b(error|failure|failed|fault)\b)",
        QRegularExpression::CaseInsensitiveOption
    };

    /// Warning keywords (e.g. "warn", "warning", "caution").
    QRegularExpression m_reWarn{
        R"(\b(warn(?:ing)?|caution)\b)",
        QRegularExpression::CaseInsensitiveOption
    };

    /// Success keywords (e.g. "success", "succeeded", "ok", "passed").
    QRegularExpression m_reSucc{
        R"(\b(success|succeeded|ok|passed)\b)",
        QRegularExpression::CaseInsensitiveOption
    };

    SerialBridge* m_bridge = nullptr; ///< Non-owning; used to hook up to incoming text lines.
};

#endif // ALARMRECEIVER_H
