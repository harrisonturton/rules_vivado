"""Information returned after synthesis"""

VivadoNetlistInfo = provider(
    "Output of design synthesis",
    fields = {
        "netlist": "(File) generated verilog netlist",
        "checkpoint": "(File) post-synthesis design checkpoint",
    },
)
