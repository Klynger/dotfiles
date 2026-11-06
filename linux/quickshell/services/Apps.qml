pragma Singleton

import Quickshell
import Quickshell.Io

// Desktop applications with the fuzzy search the launcher uses. Scoring
// prefers name prefixes, then word prefixes, substrings, keyword matches
// and finally scattered subsequences, which is close enough that
// muscle memory keeps working. Launches are remembered across restarts:
// with no query the most used apps come first, and within a match tier
// the ones launched most recently and often win.
Singleton {
    id: root

    readonly property var all: DesktopEntries.applications.values.filter(a => !a.noDisplay)

    // id -> { count, last (ms since epoch) }, persisted in the state dir
    property var history: ({})

    FileView {
        id: historyFile

        path: Quickshell.statePath("launcher-history.json")
        // Missing on the first run, which is fine: history starts empty
        printErrors: false
        onLoaded: {
            try {
                root.history = JSON.parse(text());
            } catch (e) {
                root.history = {};
            }
        }
    }

    function record(entry): void {
        const h = history[entry.id] ?? { count: 0, last: 0 };
        history[entry.id] = { count: h.count + 1, last: Date.now() };

        // Drop ids whose desktop entry is gone so uninstalls don't
        // accumulate forever
        const ids = new Set(all.map(a => a.id));
        for (const id in history) {
            if (!ids.has(id))
                delete history[id];
        }
        historyFile.setText(JSON.stringify(history));
    }

    // Launch count weighted down as the last launch ages (zoxide's buckets)
    function frecency(entry): real {
        const h = history[entry.id];
        if (!h)
            return 0;
        const age = Date.now() - h.last;
        if (age < 3600 * 1000)
            return h.count * 4;
        if (age < 24 * 3600 * 1000)
            return h.count * 2;
        if (age < 7 * 24 * 3600 * 1000)
            return h.count;
        return h.count * 0.5;
    }

    function score(entry, q: string): real {
        const name = entry.name.toLowerCase();
        if (name.startsWith(q))
            return 100 - name.length * 0.01;
        if (name.split(/\s+/).some(w => w.startsWith(q)))
            return 80;
        if (name.includes(q))
            return 60;
        const extra = (entry.genericName + " " + entry.keywords.join(" ")).toLowerCase();
        if (extra.includes(q))
            return 40;
        let i = 0;
        for (const ch of name) {
            if (ch === q[i])
                i++;
        }
        if (i === q.length)
            return 20;
        return 0;
    }

    function search(query: string): var {
        const q = query.toLowerCase().trim();
        if (q === "")
            return all.slice().sort((a, b) => frecency(b) - frecency(a) || a.name.localeCompare(b.name));
        // The frecency bonus stays under the 20-point tier gap, so it only
        // reorders apps that matched the query equally well
        return all
            .map(e => {
                const s = score(e, q);
                return [s > 0 ? s + Math.min(19, frecency(e)) : 0, e];
            })
            .filter(p => p[0] > 0)
            .sort((a, b) => b[0] - a[0] || a[1].name.localeCompare(b[1].name))
            .map(p => p[1]);
    }
}
