ADACORE_COMMUNITY = "https://community.download.adacore.com"
ALIRE_GNAT_FSF = "https://github.com/alire-project/GNAT-FSF-builds"

GNATC = "gnat-community"
ALIREC = "alire-community"

def choose_ada_comunity(d):
    compiler_provider = d.getVar('PREFERRED_PROVIDER_virtual/gnat1')
    if compiler_provider == 'adacore-gnat-native':
        return d.getVar('GNATC')
    elif compiler_provider == 'alire-gnat-native':
        return d.getVar('ALIREC')
    else:
        return "nonexistent"

ADA_COMMUNITY = "${@choose_ada_comunity(d)}"
