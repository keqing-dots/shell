#pragma once

#include <vector>

#include <qcolor.h>
#include <qelapsedtimer.h>
#include <qfont.h>
#include <qqmlintegration.h>
#include <qquickitem.h>
#include <qsgtexture.h>
#include <qstring.h>
#include <qtimer.h>

namespace keqingshell {

class MatrixGrid : public QQuickItem {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString glyphs READ glyphs WRITE setGlyphs NOTIFY glyphsChanged)
    Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged)
    Q_PROPERTY(qreal cellWidth READ cellWidth WRITE setCellWidth NOTIFY
                   cellWidthChanged)
    Q_PROPERTY(qreal cellHeight READ cellHeight WRITE setCellHeight NOTIFY
                   cellHeightChanged)
    Q_PROPERTY(int fallIntervalMs READ fallIntervalMs WRITE setFallIntervalMs
                   NOTIFY fallIntervalMsChanged)
    Q_PROPERTY(int speedVarianceTicks READ speedVarianceTicks WRITE
                   setSpeedVarianceTicks NOTIFY speedVarianceTicksChanged)
    Q_PROPERTY(qreal glyphFlickerChance READ glyphFlickerChance WRITE
                   setGlyphFlickerChance NOTIFY glyphFlickerChanceChanged)
    Q_PROPERTY(qreal boldChance READ boldChance WRITE setBoldChance NOTIFY
                   boldChanceChanged)
    Q_PROPERTY(qreal sparkChance READ sparkChance WRITE setSparkChance NOTIFY
                   sparkChanceChanged)
    Q_PROPERTY(qreal fadeStepsFrac READ fadeStepsFrac WRITE setFadeStepsFrac
                   NOTIFY fadeStepsFracChanged)
    Q_PROPERTY(qreal eraseDelayMinFrac READ eraseDelayMinFrac WRITE
                   setEraseDelayMinFrac NOTIFY eraseDelayMinFracChanged)
    Q_PROPERTY(qreal eraseDelayMaxFrac READ eraseDelayMaxFrac WRITE
                   setEraseDelayMaxFrac NOTIFY eraseDelayMaxFracChanged)
    Q_PROPERTY(qreal respawnMinFrac READ respawnMinFrac WRITE setRespawnMinFrac
                   NOTIFY respawnMinFracChanged)
    Q_PROPERTY(qreal respawnMaxFrac READ respawnMaxFrac WRITE setRespawnMaxFrac
                   NOTIFY respawnMaxFracChanged)
    Q_PROPERTY(int sweepDurationMs READ sweepDurationMs WRITE
                   setSweepDurationMs NOTIFY sweepDurationMsChanged)
    Q_PROPERTY(QColor headColor READ headColor WRITE setHeadColor NOTIFY
                   headColorChanged)
    Q_PROPERTY(QColor tailColor READ tailColor WRITE setTailColor NOTIFY
                   tailColorChanged)
    Q_PROPERTY(
        bool running READ isRunning WRITE setRunning NOTIFY runningChanged)

  public:
    explicit MatrixGrid(QQuickItem *parent = nullptr);
    ~MatrixGrid() override;

    [[nodiscard]] QString glyphs() const { return m_glyphs; }
    void setGlyphs(const QString &glyphs);

    [[nodiscard]] QFont font() const { return m_font; }
    void setFont(const QFont &font);

    [[nodiscard]] qreal cellWidth() const { return m_cellWidth; }
    void setCellWidth(qreal width);

    [[nodiscard]] qreal cellHeight() const { return m_cellHeight; }
    void setCellHeight(qreal height);

    [[nodiscard]] int fallIntervalMs() const { return m_fallIntervalMs; }
    void setFallIntervalMs(int ms);

    [[nodiscard]] int speedVarianceTicks() const {
        return m_speedVarianceTicks;
    }
    void setSpeedVarianceTicks(int ticks);

    [[nodiscard]] qreal glyphFlickerChance() const {
        return m_glyphFlickerChance;
    }
    void setGlyphFlickerChance(qreal chance);

    [[nodiscard]] qreal boldChance() const { return m_boldChance; }
    void setBoldChance(qreal chance);

    [[nodiscard]] qreal sparkChance() const { return m_sparkChance; }
    void setSparkChance(qreal chance);

    [[nodiscard]] qreal fadeStepsFrac() const { return m_fadeStepsFrac; }
    void setFadeStepsFrac(qreal frac);

    [[nodiscard]] qreal eraseDelayMinFrac() const {
        return m_eraseDelayMinFrac;
    }
    void setEraseDelayMinFrac(qreal frac);

    [[nodiscard]] qreal eraseDelayMaxFrac() const {
        return m_eraseDelayMaxFrac;
    }
    void setEraseDelayMaxFrac(qreal frac);

    [[nodiscard]] qreal respawnMinFrac() const { return m_respawnMinFrac; }
    void setRespawnMinFrac(qreal frac);

    [[nodiscard]] qreal respawnMaxFrac() const { return m_respawnMaxFrac; }
    void setRespawnMaxFrac(qreal frac);

    [[nodiscard]] int sweepDurationMs() const { return m_sweepDurationMs; }
    void setSweepDurationMs(int ms);

    [[nodiscard]] QColor headColor() const { return m_headColor; }
    void setHeadColor(const QColor &color);

    [[nodiscard]] QColor tailColor() const { return m_tailColor; }
    void setTailColor(const QColor &color);

    [[nodiscard]] bool isRunning() const { return m_running; }
    void setRunning(bool running);

  signals:
    void glyphsChanged();
    void fontChanged();
    void cellWidthChanged();
    void cellHeightChanged();
    void fallIntervalMsChanged();
    void speedVarianceTicksChanged();
    void glyphFlickerChanceChanged();
    void boldChanceChanged();
    void sparkChanceChanged();
    void fadeStepsFracChanged();
    void eraseDelayMinFracChanged();
    void eraseDelayMaxFracChanged();
    void respawnMinFracChanged();
    void respawnMaxFracChanged();
    void sweepDurationMsChanged();
    void headColorChanged();
    void tailColorChanged();
    void runningChanged();

  protected:
    QSGNode *updatePaintNode(QSGNode *oldNode,
                             UpdatePaintNodeData *updatePaintNodeData) override;
    void geometryChange(const QRectF &newGeometry,
                        const QRectF &oldGeometry) override;

  private slots:
    void onTick();
    void onSweepTick();

  private:
    // Spawn scheduler only, so overlapping sweeps stay possible.
    struct Column {
        int drawingState = -1; // -1 = not yet started
        int timer = 0;

        int speed = 1; // shared by this column's nodes so they stay in lockstep
        int wait = 0;
        bool stepNodes = false; // computed once per tick in onTick

        // Persists like curses' screen buffer - cells stay until overwritten.
        std::vector<int> glyphIndex;
        std::vector<uint8_t> age;    // 0 = just written, caps at fadeSteps - 1
        std::vector<uint8_t> bold;
        std::vector<uint8_t> spark;  // one-tick flash, consumed next step
        std::vector<uint8_t> visible;
    };

    // A moving point (writer draws, eraser clears); several can share a column.
    struct Node {
        int column = 0;
        int row = 0;
        bool isWriter = true;
        bool expired = false;
    };

    void rebuildGrid();
    void writeCell(Column &column, int row, bool spark) const;
    void eraseCell(Column &column, int row) const;
    int atlasRowFor(bool spark, bool bold, int age) const;
    int effectiveFadeSteps() const;
    int randomGlyphIndex() const;
    int randomSpeed() const;
    int randomInRowFraction(qreal minFrac, qreal maxFrac) const;
    void markAtlasDirty();
    void rebuildAtlasIfNeeded();
    void updateRainNode(QSGGeometryNode *node);

    QString m_glyphs;
    QFont m_font;
    qreal m_cellWidth = 16;
    qreal m_cellHeight = 18;
    int m_fallIntervalMs = 45;
    int m_speedVarianceTicks = 3;
    qreal m_glyphFlickerChance = 0.05;
    qreal m_boldChance = 0.5;
    qreal m_sparkChance = 0.33;
    qreal m_fadeStepsFrac = 0.6;
    qreal m_eraseDelayMinFrac = 0.3;
    qreal m_eraseDelayMaxFrac = 1.0;
    qreal m_respawnMinFrac = 0.05;
    qreal m_respawnMaxFrac = 0.5;
    int m_sweepDurationMs = 500;
    QColor m_headColor = Qt::white;
    QColor m_tailColor = Qt::transparent;
    bool m_running = false;

    QTimer m_tickTimer;
    std::vector<Column> m_columns;
    std::vector<Node> m_nodes;
    int m_columnCount = 0;
    int m_rowCount = 0;

    bool m_sweeping = false;
    int m_sweepRow = -1; // last row lit across every column, -1 = none yet
    QElapsedTimer m_sweepClock;
    QTimer m_sweepTimer;

    bool m_atlasDirty = true;
    QSGTexture *m_atlasTexture = nullptr;
    qreal m_atlasCellWidth = 0;
    qreal m_atlasCellHeight = 0;
    int m_atlasGlyphCount = 0;
    int m_atlasFadeSteps = 0;
};

} // namespace keqingshell
