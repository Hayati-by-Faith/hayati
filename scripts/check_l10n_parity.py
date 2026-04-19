"""Check ARB <-> localization.dart inline-map parity for Hayati.

Runs a quick cross-check so missing `context.l(...)` values surface locally
before CI. Not wired into CI — the canonical CI check is the ARB ar<->en
check in `.github/workflows/ci.yml`.
"""

import json
import pathlib
import re
import sys


def main() -> int:
    root = pathlib.Path(__file__).resolve().parent.parent
    en = json.loads((root / "lib/l10n/app_en.arb").read_text(encoding="utf-8"))
    ar = json.loads((root / "lib/l10n/app_ar.arb").read_text(encoding="utf-8"))
    loc = (root / "lib/core/utils/localization.dart").read_text(encoding="utf-8")

    arb_keys = {k for k in en.keys() if not k.startswith("@")}
    ar_keys = {k for k in ar.keys() if not k.startswith("@")}
    loc_keys = set(re.findall(r"'([a-z_0-9]+)':", loc))

    missing_in_map = sorted(arb_keys - loc_keys)
    extra_in_map = sorted(loc_keys - arb_keys)
    ar_en_mismatch = sorted(arb_keys.symmetric_difference(ar_keys))

    ok = True
    if ar_en_mismatch:
        ok = False
        print("ar<->en ARB key mismatch:", *ar_en_mismatch, sep="\n  ")
    if missing_in_map:
        ok = False
        print(
            "ARB keys missing from localization.dart _phase1L10n map:",
            *missing_in_map,
            sep="\n  ",
        )
    if extra_in_map:
        ok = False
        print(
            "localization.dart keys with no matching ARB entry:",
            *extra_in_map,
            sep="\n  ",
        )

    if ok:
        print(f"Localization parity OK ({len(arb_keys)} keys across ARB + map).")
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
