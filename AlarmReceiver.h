#ifndef ALARMRECEIVER_H
#define ALARMRECEIVER_H

#include <QObject>
#include <QRegularExpression>

class SerialBridge;

/**
 * @brief AlarmReceiver
 * Lightweight classifier that listens to text lines coming from SerialBridge
 * and emits semantic signals when a line looks
 * like an *error*, *warning*, or *success* message.
 *
 * Usage:
 *   - Construct with a (non-owning) SerialBridge*.
 *   - Connect SerialBridge::rxTextReceived(QString) -> onLineReceived(QString).
 *   - Bind UI logic to rxError / rxWarning / rxSuccess as needed.
 */
class AlarmReceiver : public QObject {
    Q_OBJECT
public:
    explicit AlarmReceiver(SerialBridge* bridge, QObject* parent = nullptr);

signals:
    // -----------------------
    // Classified message signals (UI can bind to these)
    // -----------------------

    /**
     * @brief rxError
     * Emitted when a line matches the error pattern (e.g., contains "error", "failure").
     * @param line The original line that triggered the match.
     */
    void rxError(const QString& line);

    /**
     * @brief rxWarning
     * Emitted when a line matches the warning pattern (e.g., "warn", "warning", "caution").
     * @param line The original line that triggered the match.
     */
    void rxWarning(const QString& line);

    /**
     * @brief rxSuccess
     * Emitted when a line matches the success pattern (e.g., "success", "ok", "passed").
     * @param line The original line that triggered the match.
     */
    void rxSuccess(const QString& line);

public slots:
    /**
     * @brief onLineReceived
     * Slot intended to be connected to SerialBridge::rxTextReceived(QString).
     * For each incoming line, runs regex classification and emits exactly one of
     * rxError / rxWarning / rxSuccess if matched; otherwise emits nothing.
     * @param line A single decoded text line (without trailing newline).
     */
    void onLineReceived(const QString& line);

private:
    /**
     * @brief classifyAndEmit
     * Helper that applies regexes in priority order (error → warning → success)
     * and emits the first matching signal. If none match, it returns silently.
     * @param line The line to classify.
     */
    void classifyAndEmit(const QString& line);

    // -----------------------
    // Patterns (case-insensitive, word-bounded where appropriate)
    // Tune these to your telemetry vocabulary.
    // -----------------------

    /// Matches typical error tokens: "error", "failure", "failed", "fault".
    QRegularExpression m_reErr{
        R"(\b(error|failure|failed|fault)\b)",
        QRegularExpression::CaseInsensitiveOption
    };

    /// Matches warning tokens: "warn", "warning", "caution".
    QRegularExpression m_reWarn{
        R"(\b(warn(?:ing)?|caution)\b)",
        QRegularExpression::CaseInsensitiveOption
    };

    /// Matches success tokens: "success", "succeeded", "ok", "passed".
    QRegularExpression m_reSucc{
        R"(\b(success|succeeded|ok|passed)\b)",
        QRegularExpression::CaseInsensitiveOption
    };

    SerialBridge* m_bridge = nullptr; ///< Non-owning; lifetime managed externally.
};

#endif // ALARMRECEIVER_H


