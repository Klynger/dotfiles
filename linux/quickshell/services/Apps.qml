pragma Singleton

import Quickshell

// Desktop applications with the fuzzy search the launcher uses. Scoring
// prefers name prefixes, then word prefixes, substrings, keyword matches
// and finally scattered subsequences, which is close enough that
// muscle memory keeps working.
Singleton {
    id: root

    readonly property var all: DesktopEntries.applications.values.filter(a => !a.noDisplay)

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
            return all.slice().sort((a, b) => a.name.localeCompare(b.name));
        return all
            .map(e => [score(e, q), e])
            .filter(p => p[0] > 0)
            .sort((a, b) => b[0] - a[0] || a[1].name.localeCompare(b[1].name))
            .map(p => p[1]);
    }
}
