pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var _browsers: ["brave", "chrome", "chromium", "epiphany", "falkon", "firefox", "floorp", "librewolf", "opera", "vivaldi", "waterfox", "zen"]
    property var _playerConn: Connections {
        function onLengthSupportedChanged() {
            root._trySetLength();
        }
        function onMetadataChanged() {
            root.trackLength = 0;
            root._updateMetadata();
            root._trySetLength();
        }
        function onPlaybackStateChanged() {
            if (!root.isSeeking && root.currentPlayer) {
                root.currentPosition = root.currentPlayer.position || 0;
                // Firefox/Zen SPA navigation skips PropertiesChanged — re-read here as fallback
                root._updateMetadata();
                root.trackLength = 0;
                root._trySetLength();
            }
        }
        function onPositionChanged() {
            if (!root.isSeeking && root.currentPlayer)
                root.currentPosition = root.currentPlayer.position || 0;
        }

        ignoreUnknownSignals: true
        target: root.currentPlayer
    }
    property var _playersConn: Connections {
        function onValuesChanged() {
            root.updateCurrentPlayer();
        }

        target: Mpris.players
    }
    property var _positionTimer: Timer {
        interval: 1000
        repeat: true
        running: root.currentPlayer !== null && !root.isSeeking && root.isPlaying

        onTriggered: {
            if (!root.currentPlayer || root.isSeeking)
                return;
            root.currentPosition = root.currentPlayer.position || 0;
            if (root.trackLength === 0 && root.currentPlayer.lengthSupported !== false) {
                var len = root.currentPlayer.length || 0;
                if (len > 0 && len < 922337203685)
                    root.trackLength = len;
            }
        }
    }
    readonly property bool canGoNext: currentPlayer?.canGoNext ?? false
    readonly property bool canGoPrevious: currentPlayer?.canGoPrevious ?? false
    readonly property bool canPause: currentPlayer?.canPause ?? false
    readonly property bool canPlay: currentPlayer?.canPlay ?? false
    readonly property bool canSeek: currentPlayer?.canSeek ?? false
    property var currentPlayer: null
    property real currentPosition: 0
    readonly property bool isPlaying: currentPlayer?.playbackState === MprisPlaybackState.Playing ?? false
    property bool isSeeking: false
    readonly property string lengthString: formatTime(trackLength)
    property var manualPlayer: null
    readonly property var players: Mpris.players?.values ?? []
    readonly property string positionString: formatTime(currentPosition)
    property string trackAlbum: ""
    property string trackArtUrl: ""
    property string trackArtist: ""
    property real trackLength: 0
    property string trackTitle: ""

    function _artUrl(player) {
        if (!player)
            return "";
        if (player.trackArtUrl)
            return player.trackArtUrl;
        var url = player.metadata ? (player.metadata["xesam:url"] ?? "") : "";
        if (url && url.startsWith("https://www.youtube.com/watch")) {
            var match = url.match(/[?&]v=([\w-]{11})/);
            return match ? "https://img.youtube.com/vi/" + match[1] + "/hqdefault.jpg" : "";
        }
        return "";
    }
    function _isBrowser(player) {
        var id = String(player?.identity ?? "").toLowerCase();
        return root._browsers.some(function (b) {
            return id.includes(b);
        });
    }
    function _trySetLength() {
        if (!root.currentPlayer || root.trackLength > 0)
            return;
        if (root.currentPlayer.lengthSupported !== false) {
            var len = root.currentPlayer.length || 0;
            if (len > 0 && len < 922337203685)
                root.trackLength = len;
        }
    }
    function _updateMetadata() {
        var p = root.currentPlayer;
        root.trackTitle = p ? (p.trackTitle ? p.trackTitle.replace(/(\r\n|\n|\r)/g, "") : "") : "";
        root.trackArtist = p ? (p.trackArtist || p.trackAlbumArtist || "") : "";
        root.trackAlbum = p?.trackAlbum ?? "";
        root.trackArtUrl = root._artUrl(p);
    }
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0)
            return "0:00";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var s = Math.floor(seconds % 60);
        var pad = function (n) {
            return n < 10 ? "0" + n : n;
        };
        return h > 0 ? h + ":" + pad(m) + ":" + pad(s) : m + ":" + pad(s);
    }
    function next() {
        if (root.currentPlayer?.canGoNext)
            root.currentPlayer.next();
    }
    function playPause() {
        if (!root.currentPlayer)
            return;
        if (root.currentPlayer.canTogglePlaying)
            root.currentPlayer.togglePlaying();
        else if (root.currentPlayer.playbackState === MprisPlaybackState.Playing)
            root.currentPlayer.pause();
        else
            root.currentPlayer.play();
    }
    function previous() {
        if (root.currentPlayer?.canGoPrevious)
            root.currentPlayer.previous();
    }
    function seek(position) {
        if (root.currentPlayer?.canSeek) {
            root.currentPlayer.position = position;
            root.currentPosition = position;
        }
    }
    function seekByRatio(ratio) {
        if (root.currentPlayer?.canSeek && root.trackLength > 0) {
            var pos = ratio * root.trackLength;
            root.currentPlayer.position = pos;
            root.currentPosition = pos;
        }
    }
    function seekRelative(offset) {
        if (root.currentPlayer?.canSeek && root.trackLength > 0) {
            var pos = Math.max(0, Math.min((root.currentPlayer.position || 0) + offset, root.trackLength));
            root.currentPlayer.position = pos;
            root.currentPosition = pos;
        }
    }
    function switchToPlayer(player) {
        if (player && player !== root.currentPlayer) {
            root.manualPlayer = player;
            root.currentPlayer = player;
            root.currentPosition = player.position || 0;
        }
    }
    function updateCurrentPlayer() {
        var all = Mpris.players ? (Mpris.players.values || []) : [];
        var available = all.filter(function (p) {
            return p && (p.playbackState === MprisPlaybackState.Playing || p.playbackState === MprisPlaybackState.Paused);
        });

        if (available.length === 0) {
            root.currentPlayer = null;
            root.manualPlayer = null;
            return;
        }

        if (root.manualPlayer && available.includes(root.manualPlayer)) {
            if (root.currentPlayer !== root.manualPlayer)
                root.currentPlayer = root.manualPlayer;
            return;
        }
        root.manualPlayer = null;

        for (let i = 0; i < available.length; i++) {
            if (available[i].playbackState === MprisPlaybackState.Playing && !root._isBrowser(available[i])) {
                if (root.currentPlayer !== available[i])
                    root.currentPlayer = available[i];
                return;
            }
        }

        for (let i = 0; i < available.length; i++) {
            if (available[i].playbackState === MprisPlaybackState.Playing) {
                if (root.currentPlayer !== available[i])
                    root.currentPlayer = available[i];
                return;
            }
        }

        for (let i = 0; i < available.length; i++) {
            if (available[i] === root.currentPlayer)
                return;
        }
        root.currentPlayer = available[0];
    }

    Component.onCompleted: updateCurrentPlayer()
    onCurrentPlayerChanged: {
        isSeeking = false;
        trackLength = 0;
        _updateMetadata();
        _trySetLength();
        if (!currentPlayer || currentPlayer.playbackState !== MprisPlaybackState.Playing)
            currentPosition = 0;
    }
}
