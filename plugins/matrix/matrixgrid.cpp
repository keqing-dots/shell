#include "matrixgrid.hpp"

#include <algorithm>
#include <cmath>

#include <QSGGeometry>
#include <QSGGeometryNode>
#include <QSGTextureMaterial>
#include <qpainter.h>
#include <qquickwindow.h>
#include <qrandom.h>

namespace keqingshell {

MatrixGrid::MatrixGrid(QQuickItem *parent) : QQuickItem(parent) {
    setFlag(ItemHasContents, true);

    m_tickTimer.setInterval(m_fallIntervalMs);
    connect(&m_tickTimer, &QTimer::timeout, this, &MatrixGrid::onTick);
}

MatrixGrid::~MatrixGrid() { delete m_atlasTexture; }

void MatrixGrid::setGlyphs(const QString &glyphs) {
    if (m_glyphs == glyphs)
        return;
    m_glyphs = glyphs;
    emit glyphsChanged();
    markAtlasDirty();
}

void MatrixGrid::setFont(const QFont &font) {
    if (m_font == font)
        return;
    m_font = font;
    emit fontChanged();
    markAtlasDirty();
}

void MatrixGrid::setCellWidth(qreal width) {
    if (qFuzzyCompare(m_cellWidth, width))
        return;
    m_cellWidth = width;
    emit cellWidthChanged();
    markAtlasDirty();
    rebuildGrid();
}

void MatrixGrid::setCellHeight(qreal height) {
    if (qFuzzyCompare(m_cellHeight, height))
        return;
    m_cellHeight = height;
    emit cellHeightChanged();
    markAtlasDirty();
    rebuildGrid();
}

void MatrixGrid::setFallIntervalMs(int ms) {
    if (m_fallIntervalMs == ms)
        return;
    m_fallIntervalMs = ms;
    m_tickTimer.setInterval(m_fallIntervalMs);
    emit fallIntervalMsChanged();
}

void MatrixGrid::setSpeedVarianceTicks(int ticks) {
    ticks = std::max(1, ticks);
    if (m_speedVarianceTicks == ticks)
        return;
    m_speedVarianceTicks = ticks;
    emit speedVarianceTicksChanged();
}

void MatrixGrid::setGlyphFlickerChance(qreal chance) {
    if (qFuzzyCompare(m_glyphFlickerChance, chance))
        return;
    m_glyphFlickerChance = chance;
    emit glyphFlickerChanceChanged();
}

void MatrixGrid::setBoldChance(qreal chance) {
    if (qFuzzyCompare(m_boldChance, chance))
        return;
    m_boldChance = chance;
    emit boldChanceChanged();
}

void MatrixGrid::setSparkChance(qreal chance) {
    if (qFuzzyCompare(m_sparkChance, chance))
        return;
    m_sparkChance = chance;
    emit sparkChanceChanged();
}

void MatrixGrid::setFadeStepsFrac(qreal frac) {
    if (qFuzzyCompare(m_fadeStepsFrac, frac))
        return;
    m_fadeStepsFrac = frac;
    emit fadeStepsFracChanged();
    markAtlasDirty();
}

void MatrixGrid::setEraseDelayMinFrac(qreal frac) {
    if (qFuzzyCompare(m_eraseDelayMinFrac, frac))
        return;
    m_eraseDelayMinFrac = frac;
    emit eraseDelayMinFracChanged();
}

void MatrixGrid::setEraseDelayMaxFrac(qreal frac) {
    if (qFuzzyCompare(m_eraseDelayMaxFrac, frac))
        return;
    m_eraseDelayMaxFrac = frac;
    emit eraseDelayMaxFracChanged();
}

void MatrixGrid::setRespawnMinFrac(qreal frac) {
    if (qFuzzyCompare(m_respawnMinFrac, frac))
        return;
    m_respawnMinFrac = frac;
    emit respawnMinFracChanged();
}

void MatrixGrid::setRespawnMaxFrac(qreal frac) {
    if (qFuzzyCompare(m_respawnMaxFrac, frac))
        return;
    m_respawnMaxFrac = frac;
    emit respawnMaxFracChanged();
}

void MatrixGrid::setSweepProgress(qreal progress) {
    progress = std::clamp(progress, 0.0, 1.0);
    if (!m_sweeping || qFuzzyCompare(m_sweepProgress, progress))
        return;
    m_sweepProgress = progress;
    emit sweepProgressChanged();

    const int targetRow =
        std::min(m_rowCount - 1, static_cast<int>(progress * m_rowCount));

    // Age rows the wavefront already lit, faster than the rain so nothing lingers.
    const int fadeSteps = effectiveFadeSteps();
    for (auto &column : m_columns) {
        for (int row = 0; row <= m_sweepRow && row < m_rowCount; row++) {
            if (!column.visible[row])
                continue;
            if (column.spark[row])
                column.spark[row] = 0;
            else if (column.age[row] < fadeSteps - 1)
                column.age[row] = static_cast<uint8_t>(std::min(
                    fadeSteps - 1, column.age[row] + m_sweepFadeMultiplier));
        }
    }

    // Light every column at once per row - a synchronized wavefront.
    for (int row = m_sweepRow + 1; row <= targetRow; row++) {
        for (auto &column : m_columns)
            writeCell(column, row, false);
    }
    m_sweepRow = std::max(m_sweepRow, targetRow);

    if (progress >= 1.0) {
        m_sweeping = false;
        m_tickTimer.start();
    }

    update();
}

void MatrixGrid::setSweepFadeMultiplier(int multiplier) {
    multiplier = std::max(1, multiplier);
    if (m_sweepFadeMultiplier == multiplier)
        return;
    m_sweepFadeMultiplier = multiplier;
    emit sweepFadeMultiplierChanged();
}

void MatrixGrid::setHeadColor(const QColor &color) {
    if (m_headColor == color)
        return;
    m_headColor = color;
    emit headColorChanged();
    markAtlasDirty();
}

void MatrixGrid::setTailColor(const QColor &color) {
    if (m_tailColor == color)
        return;
    m_tailColor = color;
    emit tailColorChanged();
    markAtlasDirty();
}

void MatrixGrid::setRunning(bool running) {
    if (m_running == running)
        return;
    m_running = running;
    emit runningChanged();

    if (m_running) {
        rebuildGrid(); // also starts the sweep, since m_running is already true
    } else {
        m_tickTimer.stop();
        m_sweeping = false;
        update();
    }
}

void MatrixGrid::geometryChange(const QRectF &newGeometry,
                                 const QRectF &oldGeometry) {
    QQuickItem::geometryChange(newGeometry, oldGeometry);

    if (m_cellWidth <= 0 || m_cellHeight <= 0)
        return;

    const int newColumnCount =
        std::max(1, static_cast<int>(width() / (m_cellWidth * 2)));
    const int newRowCount =
        std::max(1, static_cast<int>(height() / m_cellHeight));

    // Only reset when the cell count actually changes, not on every resize event.
    if (newColumnCount != m_columnCount || newRowCount != m_rowCount)
        rebuildGrid();
}

void MatrixGrid::markAtlasDirty() {
    m_atlasDirty = true;
    update();
}

int MatrixGrid::randomGlyphIndex() const {
    if (m_glyphs.isEmpty())
        return 0;
    return static_cast<int>(
        QRandomGenerator::global()->bounded(m_glyphs.size()));
}

int MatrixGrid::randomSpeed() const {
    return 1 + static_cast<int>(
                   QRandomGenerator::global()->bounded(m_speedVarianceTicks));
}

int MatrixGrid::randomInRowFraction(qreal minFrac, qreal maxFrac) const {
    const qreal frac =
        minFrac +
        QRandomGenerator::global()->generateDouble() * (maxFrac - minFrac);
    return std::max(1, static_cast<int>(m_rowCount * frac));
}

void MatrixGrid::writeCell(Column &column, int row, bool spark) const {
    if (row < 0 || row >= static_cast<int>(column.glyphIndex.size()))
        return;
    column.glyphIndex[row] = randomGlyphIndex();
    column.bold[row] =
        QRandomGenerator::global()->generateDouble() < m_boldChance;
    column.age[row] = 0;
    column.spark[row] = spark ? 1 : 0;
    column.visible[row] = 1;
}

void MatrixGrid::eraseCell(Column &column, int row) const {
    if (row < 0 || row >= static_cast<int>(column.visible.size()))
        return;
    column.visible[row] = 0;
}

int MatrixGrid::effectiveFadeSteps() const {
    // Scale with rowCount so long trails don't all fade out at the same length.
    return std::max(2, static_cast<int>(std::round(m_rowCount * m_fadeStepsFrac)));
}

int MatrixGrid::atlasRowFor(bool spark, bool bold, int age) const {
    const int fadeSteps = effectiveFadeSteps();
    if (spark)
        return 2 * fadeSteps;
    const int clampedAge = std::clamp(age, 0, fadeSteps - 1);
    return (bold ? fadeSteps : 0) + clampedAge;
}

void MatrixGrid::rebuildGrid() {
    if (m_cellWidth <= 0 || m_cellHeight <= 0)
        return;

    // Leave a gap between streams; filling every cell reads as too dense.
    m_columnCount =
        std::max(1, static_cast<int>(width() / (m_cellWidth * 2)));
    m_rowCount = std::max(1, static_cast<int>(height() / m_cellHeight));

    m_nodes.clear();
    m_columns.assign(m_columnCount, Column{});
    for (auto &column : m_columns) {
        column.glyphIndex.assign(m_rowCount, 0);
        column.age.assign(m_rowCount, 0);
        column.bold.assign(m_rowCount, 0);
        column.spark.assign(m_rowCount, 0);
        column.visible.assign(m_rowCount, 0);
        column.drawingState = -1;
        column.speed = randomSpeed();
        column.wait = 0;
        // Stagger initial wake-up so columns don't all start in lockstep.
        column.timer =
            static_cast<int>(QRandomGenerator::global()->bounded(m_rowCount));
    }

    if (m_running) {
        // Rain waits for the sweep; QML animates sweepProgress smoothly.
        m_tickTimer.stop();
        m_sweeping = true;
        m_sweepRow = -1;
        if (!qFuzzyCompare(m_sweepProgress, 0.0)) {
            m_sweepProgress = 0.0;
            emit sweepProgressChanged();
        }
        emit sweepStarted();
    }

    update();
}

void MatrixGrid::onTick() {
    // Shared per-column throttle keeps that column's nodes in lockstep.
    for (auto &column : m_columns) {
        if (column.wait > 0) {
            column.wait -= 1;
            column.stepNodes = false;
        } else {
            column.wait = column.speed;
            column.stepNodes = true;
        }
    }

    // Age before fresh writes, so a new cell gets one full tick at brightest.
    const int fadeSteps = effectiveFadeSteps();
    for (auto &column : m_columns) {
        if (!column.stepNodes)
            continue;
        for (int row = 0; row < m_rowCount; row++) {
            if (!column.visible[row])
                continue;
            if (column.spark[row]) {
                column.spark[row] = 0;
            } else if (column.age[row] < fadeSteps - 1) {
                column.age[row] += 1;
            }
        }
    }

    // Spawns run independent of already-running nodes, so sweeps can overlap.
    for (int c = 0; c < static_cast<int>(m_columns.size()); c++) {
        Column &column = m_columns[c];
        if (column.timer > 0) {
            column.timer -= 1;
            continue;
        }

        const bool nowDrawing = column.drawingState != 1;
        column.drawingState = nowDrawing ? 1 : 0;

        Node node;
        node.column = c;
        node.row = 0;
        node.isWriter = nowDrawing;

        if (nowDrawing) {
            column.timer =
                randomInRowFraction(m_eraseDelayMinFrac, m_eraseDelayMaxFrac);
            const bool spark =
                QRandomGenerator::global()->generateDouble() < m_sparkChance;
            writeCell(column, 0, spark);
        } else {
            column.timer =
                randomInRowFraction(m_respawnMinFrac, m_respawnMaxFrac);
            eraseCell(column, 0);
        }

        m_nodes.push_back(node);
    }

    for (auto &node : m_nodes) {
        if (node.expired)
            continue;
        Column &column = m_columns[node.column];
        if (!column.stepNodes)
            continue;

        node.row += 1;

        if (node.row >= m_rowCount) {
            node.expired = true;
        } else if (node.isWriter) {
            writeCell(column, node.row, false);
        } else {
            eraseCell(column, node.row);
        }
    }

    m_nodes.erase(std::remove_if(m_nodes.begin(), m_nodes.end(),
                                  [](const Node &n) { return n.expired; }),
                  m_nodes.end());

    // Occasionally re-roll a visible glyph so the rain looks alive.
    if (m_glyphFlickerChance > 0 && m_rowCount > 0) {
        for (auto &column : m_columns) {
            if (QRandomGenerator::global()->generateDouble() >=
                m_glyphFlickerChance)
                continue;
            const int row = static_cast<int>(
                QRandomGenerator::global()->bounded(m_rowCount));
            if (column.visible[row])
                column.glyphIndex[row] = randomGlyphIndex();
        }
    }

    update();
}

void MatrixGrid::rebuildAtlasIfNeeded() {
    const int glyphCount = std::max(1, static_cast<int>(m_glyphs.size()));
    const int fadeSteps = effectiveFadeSteps();

    if (!m_atlasDirty && m_atlasTexture &&
        qFuzzyCompare(m_atlasCellWidth, m_cellWidth) &&
        qFuzzyCompare(m_atlasCellHeight, m_cellHeight) &&
        m_atlasGlyphCount == glyphCount && m_atlasFadeSteps == fadeSteps)
        return;

    const int cellW = static_cast<int>(std::ceil(m_cellWidth));
    const int cellH = static_cast<int>(std::ceil(m_cellHeight));
    const int atlasRows = 2 * fadeSteps + 1;

    QImage atlas(cellW * glyphCount, cellH * atlasRows,
                 QImage::Format_ARGB32_Premultiplied);
    atlas.fill(Qt::transparent);

    QPainter painter(&atlas);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setRenderHint(QPainter::TextAntialiasing);

    QFont regularFont = m_font;
    regularFont.setBold(false);
    QFont boldFont = m_font;
    boldFont.setBold(true);

    for (int g = 0; g < glyphCount; g++) {
        const QString glyph =
            m_glyphs.isEmpty() ? QString() : QString(m_glyphs.at(g));

        const auto drawCell = [&](int atlasRow, const QFont &font,
                                   const QColor &color) {
            painter.setFont(font);
            painter.setPen(color);
            const QRectF cellRect(g * cellW, atlasRow * cellH, cellW, cellH);
            painter.drawText(cellRect, Qt::AlignCenter, glyph);
        };

        for (int age = 0; age < fadeSteps; age++) {
            QColor color = m_tailColor;
            if (age == 0) {
                color = m_headColor;
            } else {
                const qreal fade =
                    1.0 - static_cast<qreal>(age) / static_cast<qreal>(fadeSteps - 1);
                color.setAlpha(static_cast<int>(m_tailColor.alpha() * fade));
            }
            drawCell(age, regularFont, color);
            drawCell(fadeSteps + age, boldFont, color);
        }
        drawCell(2 * fadeSteps, regularFont, Qt::white);
    }
    painter.end();

    delete m_atlasTexture;
    m_atlasTexture = window()->createTextureFromImage(atlas);

    m_atlasCellWidth = m_cellWidth;
    m_atlasCellHeight = m_cellHeight;
    m_atlasGlyphCount = glyphCount;
    m_atlasFadeSteps = fadeSteps;
    m_atlasDirty = false;
}

void MatrixGrid::updateRainNode(QSGGeometryNode *node) {
    if (!node->material()) {
        auto *material = new QSGTextureMaterial;
        material->setTexture(m_atlasTexture);
        material->setFiltering(QSGTexture::Linear);
        node->setMaterial(material);
        node->setFlag(QSGNode::OwnsMaterial);
    } else {
        static_cast<QSGTextureMaterial *>(node->material())
            ->setTexture(m_atlasTexture);
    }

    auto *geometry = node->geometry();
    if (!geometry) {
        geometry = new QSGGeometry(QSGGeometry::defaultAttributes_TexturedPoint2D(),
                                    0);
        geometry->setDrawingMode(QSGGeometry::DrawTriangles);
        node->setGeometry(geometry);
        node->setFlag(QSGNode::OwnsGeometry);
    }

    const qreal atlasWidth = m_atlasCellWidth * m_atlasGlyphCount;
    const qreal atlasHeight = m_atlasCellHeight * (2 * m_atlasFadeSteps + 1);

    // Center the grid; content width excludes the gap after the last column.
    const qreal contentWidth = m_columnCount * m_cellWidth * 2 - m_cellWidth;
    const qreal offsetX = (width() - contentWidth) / 2.0;
    const qreal offsetY = (height() - m_rowCount * m_cellHeight) / 2.0;

    std::vector<QSGGeometry::TexturedPoint2D> built;
    built.reserve(m_columns.size() * m_rowCount * 6);

    for (int c = 0; c < static_cast<int>(m_columns.size()); c++) {
        const auto &column = m_columns[c];

        for (int row = 0; row < m_rowCount; row++) {
            if (!column.visible[row])
                continue;

            const int glyphIndex = column.glyphIndex[row];
            const int atlasRow = atlasRowFor(column.spark[row], column.bold[row],
                                              column.age[row]);

            const qreal tx1 = (glyphIndex * m_atlasCellWidth) / atlasWidth;
            const qreal tx2 =
                ((glyphIndex + 1) * m_atlasCellWidth) / atlasWidth;
            const qreal ty1 = (atlasRow * m_atlasCellHeight) / atlasHeight;
            const qreal ty2 = ((atlasRow + 1) * m_atlasCellHeight) / atlasHeight;

            const qreal x1 = offsetX + c * m_cellWidth * 2;
            const qreal x2 = x1 + m_cellWidth;
            const qreal y1 = offsetY + row * m_cellHeight;
            const qreal y2 = y1 + m_cellHeight;

            QSGGeometry::TexturedPoint2D v;
            v.set(x1, y1, tx1, ty1);
            built.push_back(v);
            v.set(x1, y2, tx1, ty2);
            built.push_back(v);
            v.set(x2, y1, tx2, ty1);
            built.push_back(v);
            v.set(x1, y2, tx1, ty2);
            built.push_back(v);
            v.set(x2, y2, tx2, ty2);
            built.push_back(v);
            v.set(x2, y1, tx2, ty1);
            built.push_back(v);
        }
    }

    geometry->allocate(static_cast<int>(built.size()));
    if (!built.empty())
        std::copy(built.begin(), built.end(),
                   geometry->vertexDataAsTexturedPoint2D());

    node->markDirty(QSGNode::DirtyGeometry | QSGNode::DirtyMaterial);
}

QSGNode *MatrixGrid::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) {
    rebuildAtlasIfNeeded();

    auto *node = static_cast<QSGGeometryNode *>(oldNode);
    if (!node)
        node = new QSGGeometryNode;

    updateRainNode(node);

    return node;
}

} // namespace keqingshell
