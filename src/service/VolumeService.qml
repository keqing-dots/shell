pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

QtObject {
    id: root

    property PwObjectTracker _tracker: PwObjectTracker {
        objects: root.nodes.concat([root.sink, root.source])
    }
    readonly property var inputSources: nodes.filter(n => _mediaClass(n) === "Audio/Source")
    readonly property var nodes: Pipewire.nodes?.values ?? []
    readonly property var outputSinks: nodes.filter(n => _mediaClass(n) === "Audio/Sink")
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool sinkMuted: sink?.audio?.muted ?? false
    readonly property real sinkVolume: sink?.audio?.volume ?? 0
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool sourceMuted: source?.audio?.muted ?? false
    readonly property real sourceVolume: source?.audio?.volume ?? 0

    function _mediaClass(n) {
        return n?.properties?.["media.class"] ?? "";
    }
    function setSinkMuted(m) {
        if (sink?.audio)
            sink.audio.muted = m;
    }
    function setSinkVolume(v) {
        if (sink?.audio) {
            sink.audio.volume = v;
            if (v > 0)
                sink.audio.muted = false;
        }
    }
    function setSourceMuted(m) {
        if (source?.audio)
            source.audio.muted = m;
    }
    function setSourceVolume(v) {
        if (source?.audio) {
            source.audio.volume = v;
            if (v > 0)
                source.audio.muted = false;
        }
    }
}
