"""Valida el porcentaje de líneas cubiertas de un archivo LCOV."""

from pathlib import Path
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print("Uso: check_coverage.py <lcov.info> <mínimo>")
        return 2

    path = Path(sys.argv[1])
    minimum = float(sys.argv[2])
    if not path.exists():
        print(f"No se encontró el reporte: {path}")
        return 2

    found = hit = 0
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("LF:"):
            found += int(line[3:])
        elif line.startswith("LH:"):
            hit += int(line[3:])

    coverage = 100.0 if found == 0 else hit * 100.0 / found
    print(f"Cobertura de líneas: {coverage:.2f}% (mínimo {minimum:.2f}%)")
    return 0 if coverage >= minimum else 1


if __name__ == "__main__":
    raise SystemExit(main())

