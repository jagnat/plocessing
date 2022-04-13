## Plocessing - Pen plotter sketches written in processing

Small little library of sketches/tools I'm writing to export SVG files of processing sketches for the purposes of plotting them on my 3d printer using the [plotter attachment](https://www.printables.com/model/63385-pen-plotter-attachment-for-prusa-mk3s) I found on printables.


I export SVG files from the code in this repo and import them into inkscape to use [this J Tech Laser](https://github.com/JTechPhotonics/J-Tech-Photonics-Laser-Tool) inkscape extension to convert them into gcode for my printer. Following the tutorial readme in the extension repo will get you far, but by trial and error I've found the best settings in the J Tech tool for my Prusa MK3S+:

- Disable the settings in the J Tech tool to turn off/on laser before/after jobs.
- Coordinate system
  - Set the bed width and length to your printer spec (250mm x 210mm for me) so you can make sure that the gcode fits.
  - Measure your gcode x and y offsets with your printer beforehand to align the pen.
    - Using your printer's move menu, move your printer z upwards, install the plotter with your desired pen, and move the x and y-axes so that pen point is on the bottom left corner of the bed
    - The x and y position with the pen in the corner are what you can use for gcode x/y offsets in inkscape, the y-offset may need to be negated.
    - Your bed size minus these measured values is the true area your printer can plot.
  - Do some square test prints tracing slightly inside the border of the area you think you can print within, to make sure you can cover your entire expected area.
- Tool power command should be pen raise / pen lower gcode commands
  - Pen Down: `G1 Z9 F1200`
    - I've found 9mm to be more reliable than the 10mm specified by the creator of the plotter attachment. Start with larger values and work your way down in increments if you want to be safe. Don't use a tense rubber band on the plotter attachment either, it works best if the pen has some vertical give.
  - Pen Up: `G1 Z13 F1200`
- Prusa i3-specific header gcode:
  - ```
    G28; Home axes and do bed leveling
    M601; Prusa pause
    G4 S1; Delay 1 second after resuming
    ```
  - This lets me install the pen after leveling the bed, since it gets in the way of the leveling routine. I then resume the print manually so it begins plotting.
- Footer gcode:
  - ```
    G1 Z80; Pen up a liberal amount to allow access to paper. Adjust this value if you want
    G1 X0 Y200 F3000; Move x-axis out of the way and y-axis forward
    M84; Idle motors
    ```