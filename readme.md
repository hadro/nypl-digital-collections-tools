# NYPL Digital Collections Tools

A set of python and bash scripts that do useful things for NYPL Digital Collections materials, such as:
- Create a basic, small-ish PDF from a UUID (`createPDF.py`)
- Create a searchable PDF for a text-based Digital Collections item (`OCRmyPDF.sh`)

Some of this is specific to NYPL Digital Library program, but some of it should hopefully be generalizable (and, optimizable -- my coding skills barely rise above copying and pasting from blog posts, so pull requests welcome!).

Generally, you'll need: 
- Python
- ImageMagick (for PDF creation and OCR prep)
- PDFtk (for PDF creation)
- Tesseract (for OCR)
- GNU Parallel (optional, but extremely useful for parallel processing image files since Tesseract is a slow but discrete process)

You'll also need to create a `config.py` file that contains your API key for the Digital Collections API.

If you want to use GNU Parallel and the `distributed.sh` script, you'll need create a `nodeslist` file based on the `nodeslist.example` files, which will contain the IP address of the machines you will connect to via SSH, and 
(Basically, follow the instructions here: https://spectraldifferences.wordpress.com/2015/04/26/execute-commands-on-multiple-computers-using-gnu-parallel-setting-up-a-cluster-on-the-cheap/)


## Credit and thanks
The original possibility of a multi-layered PDF that balances good OCR with reasonable page-size and image quality came from a script in a comment section here: https://github.com/jbarlow83/OCRmyPDF/issues/8
Also, more generally, a lot of my process and understanding of these tools in general stems directly from Ryan Baumann's post here: #https://ryanfb.github.io/etc/2014/11/13/command_line_ocr_on_mac_os_x.html
(Particularly the small but mighty comment in footnote 3, which sent me down a weeks-long wonderful GNU Parallel rabbit hole!)