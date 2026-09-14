# ----- Imports -----
from sage.graphs.graph_latex import check_tkz_graph
from sage.misc.viewer import viewer
import dot2tex
import sage.misc.viewer
from sys import platform

# ----- LATEX RENDERING SETUP -----
if platform == "linux" or platform == "linux2":
    # Settings that worked for me on Linux Mint
    view_type = 'flatpak-spawn --host xdg-open'
    sage.misc.viewer.BROWSER = view_type
    viewer.png_viewer(view_type)
    viewer.pdf_viewer(view_type)
elif platform == "win32":
    pass # Unsure if any setting need changing on windows



# ----- Functions -----
def generate(Lambda, n):
    """Create a new CrystalOfTableaux_with_category with vertices as SSYT with values from 1 to n in shape Lambda."""
    B = crystals.Tableaux(['A',n-1], shape=Lambda)
    return B

def ranking(crystal, colors = [], depth = Infinity):
    '''
    Convert a crystal to a digraph of given 'depth' with edges from 'colors' contracted.
    
    INPUT:

    * "crystal" -- a sage crystal digraph object

    * "colors" -- a list of colors to be contracted

    * "depth" -- a bound on the layers down from the root

    OUTPUT: a digraph reduction of "crystal"
    '''
    digraph = crystal.subcrystal(max_depth = depth).digraph()
    digraph.contract_edges(list(filter(lambda e: e[2] in colors, digraph.edges())))
    print('Ranked')
    return digraph

def display(graph, option = '-d', label_list = [], vertex_limit = 200, log = False):
    '''
    Display a given 'graph' with edges labeled w.r.t. the options.
    When the vertices exceed 'vertex_limit' it confirms if you want to 
    continue displaying.

    INPUT:

    * "graph" -- a sage graph

    * "option" -- the option str to use for labelling of the following options / characters
      -A -- (A-Z) ordered uppercase english 
      -a -- (a-z) ordered lowercase english 
      -d --   #   use the default edge labels
      -l -- [-n]  indexes "label_list" with the ordered numerals
      -n -- (1-9) ordered arabic numerals 
      -r --       removes the edge labels

    * "label_list" -- the list of labels when option '-l' is selected

    * "vertex_limit" -- the vertex limit to give the option to stop

    * "log" -- a boolean which toggles print statement and forces a strict vertex limit

    OUTPUT: display typeset graph

    The output is displayed using the built in 'view' method,
    and handeled by dot2tex and sage.misc.viewer.
    '''

    if log: print("Displaying ...")
    vertexCount = len(graph.vertices())
    if(vertexCount > vertex_limit):
        if log: response = input("\tThere are {} vertices. Would you like to continue (y/n): ".format(vertexCount))
        if(not log & response not in ['y', 'Y', 'Yes', 'yes', 'n', 'N', 'No', 'no']): 
            raise(ValueError('Response invalid, please select "y" or "n"\nProcess aborted'))
        if(not log or response in ['n', 'N', 'No', 'no']):
            print('\tGraph too large\nDisplaying stopped')
            return -1
        if log: print('\tGraph sufficiently small\n\tContinuing ...')
        
    l_index = dict(map(lambda e: (e[1], e[0]), enumerate(sorted(list(set(graph.edge_labels()))))))

    label_options = {'-A': lambda c: chr(l_index[c]+65),
                     '-a': lambda c: chr(l_index[c]+97),
                     '-b': lambda c: "",
                     '-d': lambda c: c,
                     '-l': label[l_index[c]],
                     '-n': lambda c: str(l_index[c])}

    if(option not in label_options.keys()): raise(ValueError('Provided "option" is invalid. See docstring for use'))

    for e in graph.edges():
        graph.set_edge_label(e[0], e[1], label_options[option](e[2]))
        
    view(graph, tightpage=True)
    if log: print("Done!")

def render(Lambda, n, option = 'default', label_list = [] , null_edges = [], depth = Infinity, vertex_limit = 100):
    '''
    Renders a crystal graph generated with size n and shape Lambda.

    INPUT:

    * "Lambda" -- the shape of the base crystal graph

    * "n" -- the number of allowed entries in the SSYTs

    * "option" -- the option str to use for labelling of the following options / characters
      -A -- (A-Z) ordered uppercase english 
      -a -- (a-z) ordered lowercase english 
      -d --   #   use the default edge labels
      -n -- (0-9) ordered arabic numerals 
      -r --       removes the edge labels
      -l -- [-n]  indexes "label_list" with the ordered numerals
    
    * "label_list" -- the list of labels when option '-l' is selected

    * "null_edges" -- a list of edge colors to be contracted

    * "depth" -- a bound on the layers down from the root

    * "vertex_limit" -- the vertex limit to give the option to stop
    '''
    B = generate(Lambda, n)
    G = ranking(B, colors=null_edges, depth = depth)
    display(G, label=label, vertex_limit=vertex_limit, log=True)
