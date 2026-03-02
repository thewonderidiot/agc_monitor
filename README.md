# AGC Monitor

This is a modern reimplementation of the AGC Monitor, for use with a real Apollo Guidance Computer. The panel layout and behavior were implemented according to pictures and descriptions from [E-2026, User's Guide to the AGC Monitor (Core Rope Simulator)](https://virtualagc.github.io/virtualagc/Documents/HSI-208487.pdf). Both the descriptions and pictures in this document leave a lot to be desired, so best guesses were made where concrete information was not available. All logic is implemented in a [Numato Lab Styx Z7 FPGA Module](https://numato.com/product/styx-zynq-7020-fpga-module), which is connected to the AGC via interface circuits powered by the AGC itself. Host interfacing is done via FTDI Synchronous FIFO. The host GUI is implemented in python using PySide2.

An early version of this project was shown in [episode 8 of the Apollo Guidance Computer Restoration video series](https://www.youtube.com/watch?v=ThOXgcOOA1M&list=PL-_93BVApb59FWrLZfdlisi_x7-Ut_-w7&index=11), and it played a central role for the rest of the restoration.

<img width="1699" height="882" alt="Image" src="https://github.com/user-attachments/assets/3f639e80-a013-4535-bdf8-29db992bb461" />

*Original AGC Monitor panel and modern GUI*

<img width="1873" height="937" alt="Image" src="https://github.com/user-attachments/assets/50c528af-2a6d-411e-8d6c-65037d3eaaa1" />

*Monitor board installed in an AGC for testing*
