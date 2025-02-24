"""Information returned after synthesis"""

VivadoBitstreamInfo = provider(
    "Output of bitstream generation",
    fields = {
        "bitstream": "(File) generated bitstream",
        "checkpoint": "(File) post-bitstream Vivado checkpoint",
    },
)
