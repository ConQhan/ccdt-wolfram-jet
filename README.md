# Centrifugal Compressor Design Tool

MATLAB app for the preliminary design of a single-stage centrifugal compressor
(Aungier meanline method), made for a micro turbojet.

## Start

Run `launch.m` in MATLAB (R2023a or newer, no toolboxes needed).

## What it does

1. **Inputs** - operating point, machine data, sweep grid, selection limits
2. **Sweep** - r2 x inlet hub radius sweep with plots; pick a design
3. **Design point** - station states and Aungier design checklist
4. **Blade & meridional** - blade / wrap angle distributions, meridional section
5. **CFturbo inputs** - values to enter in CFturbo, screen by screen
6. **CFturbo export check** - checks the TurboGrid export before meshing
7. **Stator sizing** - vaned diffuser + 90 deg bend + axial guide vanes
8. **Compressor map** - off-design speed lines

**Export results** writes all tables (CSV) and figures (PNG) to `output/`.

## Folders

- `app/` user interface
- `api/` functions behind the app (also usable from scripts, see `examples/`)
- `lib/` meanline model (comments partly in Turkish)
- `tests/` regression tests: `runtests('tests')`

## Reference

R. H. Aungier, *Centrifugal Compressors: A Strategy for Aerodynamic Design and Analysis*, ASME Press, 2000.

## License

Developed by Fatihhan Toprak for the Wolfram Jet team.

Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/): free to use, share and modify for non-commercial purposes, with credit to the author; modified versions must be shared under the same license. Commercial use is not permitted. See `LICENSE`.
