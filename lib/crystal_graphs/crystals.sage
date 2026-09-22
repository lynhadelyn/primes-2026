# ----- IMPORTS -----
load("imports.sage")
from sage.graphs.graph_latex import check_tkz_graph
from sage.misc.viewer import viewer
import dot2tex
import sage.misc.viewer
from sys import platform
import itertools
import functools
import sage.logic.propcalc as propcalc
import re
import unittest

# ----- LATEX RENDERING SETUP -----
if platform == "linux" or platform == "linux2":
    # Settings that worked for me on Linux Mint
    view_type = 'flatpak-spawn --host xdg-open'
    sage.misc.viewer.BROWSER = view_type
    viewer.png_viewer(view_type)
    viewer.pdf_viewer(view_type)
elif platform == "win32":
    pass # Unsure if any setting need changing on windows

# ----- TYPE DEFINITIONS -----
type Crystal = sage.combinat.crystals.tensor_product.CrystalOfTableaux_with_category
type Digraph = sage.graphs.digraph.DiGraph
type Matrix = sage.matrix
type Rank = int | sage.rings.infinity.PlusInfinity
type Partition = list[int]
type Cartan = 'A' | 'B' | 'C' | 'D'

class CrystalInterface:
    '''
    A collection of static methods and options for the user to access crystals.

    VARIABLES:

    * "vertex_limit" -- the vertex limit to give the option to stop

    * "log" -- a boolean which toggles print statement and removes and prompts

    '''

    # ----- Class specific types -----
    type Option = '-A' | '-a' | '-d' | '-l' | '-n' | '-r'

    # ----- Interface Options -----
    vertex_limit: Rank = 50
    log: bool = False

    @staticmethod
    def generate(Lambda: Partition, n: int, /, type:Cartan = 'A') -> Crystal:
        """Create a new crystal with vertices as SSYT with values from 1 to n in shape Lambda."""
        B = crystals.Tableaux([type,n-1], shape=Lambda)
        return B

    def _verify(self, count: int) -> bool:
        '''Prompt the user to stop when the vertex count exceeds it's limit'''
        if(count > self.vertex_limit):
            if(not self.log):
                print('\tGraph too large\nDisplaying stopped')
                return  False
            else:
                response = input("\tThere are {} vertices. Would you like to continue (y/n): ".format(count))
                if(response not in ['y', 'Y', 'Yes', 'yes', 'n', 'N', 'No', 'no']): 
                    raise(ValueError('Response invalid, please select "y" or "n"\nProcess aborted'))
                    return False
                if(response in ['n', 'N', 'No', 'no']):
                    print('\tGraph too large\nDisplaying stopped')
                    return  False
                if self.log: print('\tGraph sufficiently small\n\tContinuing ...')
        return True

    def display(self, graph: Digraph, /, option:Option = '-d', *, label_list:list[...] = []) -> None:
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

        OUTPUT: display typeset graph

        The output is displayed using the built in 'view' method,
        and handeled by dot2tex and sage.misc.viewer.
        '''

        if self.log: print("Displaying ...")
        if not self._verify(len(graph.vertices())): return
            
        l_index = dict(map(lambda e: (e[1], e[0]), enumerate(sorted(list(set(graph.edge_labels()))))))

        label_options = {'-A': lambda c: chr(l_index[c]+65),
                        '-a': lambda c: chr(l_index[c]+97),
                        '-b': lambda c: "",
                        '-d': lambda c: c,
                        '-l': lambda c: label_list[l_index[c]],
                        '-n': lambda c: str(l_index[c])}

        for e in graph.edges():
            graph.set_edge_label(e[0], e[1], label_options[option](e[2]))
            
        view(graph, tightpage=True)
        if self.log: print("Done!")
        return

    def render(self, Lambda: Partition, n:int, /, option:Option = '-d', *, label_list:list[...] = [] , null_edges:list[int] = [], depth:Rank = Infinity) -> None:
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
        '''
        B = CrystalInterface.generate(Lambda, n)
        G = CrystalOperations.ranking(B, colors=null_edges, depth = depth)
        self.display(G, option=option)

        return

class CrystalInterface_tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        pass  

    def test_effective(self):
        #TODO: Implement Tests
        pass

class LinearOperations:
    '''
    Operate on the effective space for a system.
    '''

    @staticmethod
    def effective(equations: list) -> Matrix:
        '''Compute a matrix with column space the effective space, given equations'''
        #TODO: Implement function
        pass

class LinearOperations_tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        pass  

    def test_effective(self):
        #TODO: Implement tests
        pass

class CrystalOperations:
    '''
    Operate on crystals graphs to investigate morphisms.
    '''

    @staticmethod
    def ranking(crystal: Crystal, /, colors:list[int] = [], depth:Rank = Infinity) -> Digraph:
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
        return digraph

    @staticmethod
    def compute_ortho(graph: Digraph, /) -> dict[int, set[int]]:
        '''
        Compute orthogonality relations for edges.

        INPUT:

        * "crystal" -- The crystal graph considered to have edges remapped

        ALGORITHM:

        Each pair (c,l) in the output represents two edge colors where at least one 
        edge colored c is not incident to and edge l. Since the edges and vertices
        grow much larger than the colors, it is efficient to iterate through colors.

        For each c, eliminate colors l until none are left or all edges c are searched.
        This requires a copy of the graph with edges-reverse so that ingoing edges 
        are quickly acessed. This process can be paralleized and run across the edges
        to avoid needing to sort by colours.
        
        '''
        #TODO: ensure this works, or scrap in favour of tranfer conditions.
        dualgraph = graph.reverse()
        edge_colors = set(graph.edge_labels())
        ortho = dict.fromkeys(edge_colors, edge_colors)

        for e in graph.edges(): # Go through edges u->v
            if(ortho[e[2]] == set()): # If all colors are invalid,
                continue  # no processing is needed for this color
            ortho[e[2]] = ortho[e[2]]\
                .intersection( # Add invalids from orthogonality dict
                    set( 
                        map(lambda e: e[2], # Access color
                            itertools.chain(
                                graph.outgoing_edge_iterator(e[0]), # Iterate over the outgoing edges of u
                                dualgraph.outgoing_edge_iterator(e[1]))))) # Iterate over the incoming edges to v

        ortho = {i: edge_colors - ortho[i] for i in edge_colors} # Take the complement of the values to recover the invalid edges

        return ortho

    @staticmethod
    def transfer_conditions(graph:Digraph, /) -> dict[int, str]:
        '''
        Compute transfers based on conditional equalities

        INPUT:

        * "graph" -- The digraph to operate on

        ALGORITHM:

        An transfer property (c,l) requires some condition X. The property says that c can trasnfer to l + c'
        where l is another color, and c' a new variable. The condition X states requirements of 0 degree equations.
        This means requirements of th form c = l, or c = 0. A useful fact is that every orthogonality fails under some 
        condition, and exists under another.

        OUTPUT:

        Returns a map from colors to boolean formulas which correspond to equalities that allow transfers.
        '''
        
        dualgraph = graph.reverse()
        edge_colors = set(graph.edge_labels())
        variables = {n: "c" + str(n) for n in edge_colors}
        conditions = {t: [] for t in edge_colors}

        for e in graph.edges(): # Go through edges u->v
            T = set( # Compute the transfer set of an edge
                map(lambda e: e[2], # Access color
                    itertools.chain(
                        graph.outgoing_edge_iterator(e[0]), # Iterate over the outgoing edges of u
                        dualgraph.outgoing_edge_iterator(e[1])))) # Iterate over the incoming edges to v
            # Restrict the conditions on each transfer from e[2]
            statement = '('+'|'.join([variables[t] for t in T])+')'
            conditions[e[2]].append(statement)
 
        for c in conditions.keys():
            conditions[c]=CrystalOperations.process_condition(conditions[c])

        return conditions

    @staticmethod
    def process_condition(condition: list[str], /) -> str:
        '''
        Applies string formatting and poset structure to simplify the boolean sentence.
        '''
        #assert()                                                       #TODO:? Ensure input protection for non-conditions
        formula = propcalc.formula('~(' + '&'.join(condition) + ')')    # Negate the expression directly
        formula.convert_cnf() 
        expression = str(formula)
        #assert()                                                       #TODO:? Ensures some input constraints on the expression
        De_Morgan_order = [                                         #   Apply regular expressions to compute 
                                                                    #   ~formula using De Morgan's Laws
            ('~c', 'C'),                                                # Mark relevant variables with C
            ('(?<=\\|)?c[0-9]*(?=\\|)?', ''),                           # Remove irrelevant ones
            ('C', 'c'),                                                 # Set relevant variables
            ('\\|+', '|'),                                              # Remove multiples of or
            ('\\&+', '&'),                                              # Remove multiples of and
            ('(^\\&)|(\\&$)|((?<=\\()\\|)|(\\|(?=\\)))', ''),           # Remove dangling 'or' and dangling 'and'
            ('\\(|\\)', '')]                                            # Remove brackets
        for (x,y) in De_Morgan_order:                                   # Iterate through replacements (x->y) above
            expression = re.sub(x, y, expression)                       # Use regex find and replace method on (x, y)
        order = [frozenset(X.split('|'))                            #   Collect the expressions as sets
                    for X in expression.split('&')]                     # Split the expression over & and |
        P = Poset((order, lambda x,y: x.issubset(y)))                   # Treat the equality conditions as vertices 
                                                                        #   of a poset to find a basis
        generators = map(lambda x: sorted(list(x)),                     # Map sets to sorted lists
                         P.minimal_elements())
        generators = sorted(generators,                                 # Find and sort the minimal elements
                            key = functools.cmp_to_key(lambda x,y:      # Creat a key from a comparison
                                1 if (len(x),x)>(len(y),y) else -1))    # Use length followed by lexicographic order
        expression_simple = '|'.join([                                  # Reformat into a string expression
                '(' + '&'.join(sorted(list(X))) + ')'                   # Joining over & and | with brackets
                for X in generators])
        return expression_simple                                        # Return the string value

    @staticmethod
    def compare_conditions(cond_1, cond_2):
        #TODO: implement a cross term function to compare conditions generated from two graphs.
        pass

class CrystalOperations_tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.Interface = CrystalInterface()
        cls.Interface.vertex_limit = 0
        cls.Interface.log = False

        cls.test_crystal_1 = CrystalInterface.generate([1,1],8,type='A')
        cls.test_crystal_2 = CrystalInterface.generate([2,1],4,type='C')
        cls.test_graph_1 = DiGraph([(0,1,'1'),(1,2,'1'),(0,3,'3'),(3,2,'4')])
        cls.test_graph_2 = DiGraph([(0,1,'1'),(1,2,'2'),(0,2,'3'),(0,3,'4'),(1,3,'2')])
        cls.test_graph_3 = CrystalOperations.ranking(cls.test_crystal_1)
        cls.test_graph_4 = CrystalOperations.ranking(cls.test_crystal_2)
        

    def test_ranking(self):
        #TODO: Write tests
        pass

    def test_transfer_conditions(self):
        with self.subTest('Generic 1'):
            self.assertEqual(CrystalOperations.transfer_conditions(
                self.test_graph_1),
                {'1':'(c1)|(c3&c4)', '3':'(c1)|(c3)', '4':'(c1)|(c4)'})
        with self.subTest('Generic 2'):
            self.assertEqual(CrystalOperations.transfer_conditions(
                self.test_graph_2),
                {'1':'(c1)|(c3)|(c4)','2':'(c2)|(c3&c4)','3':'(c1)|(c2)|(c3)|(c4)','4':'(c1)|(c2)|(c3)|(c4)'})
        with self.subTest('Consistent 1'):
            self.assertEqual(CrystalOperations.transfer_conditions(
                self.test_graph_3),{
                    1: '(c1)|(c3&c5&c7)|(c3&c4&c6&c7)',
                    2: '(c2)',
                    3: '(c3)|(c1&c5&c7)',
                    4: '(c4)|(c1&c2&c6&c7)',
                    5: '(c5)|(c1&c3&c7)',
                    6: '(c6)',
                    7: '(c7)|(c1&c3&c5)|(c1&c2&c4&c5)'})
        with self.subTest('Consistent 2'):
            self.assertEqual(CrystalOperations.transfer_conditions(
                self.test_graph_4),{
                    1: '(c1)',
                    2: '(c2)',
                    3: '(c3)|(c1&c2)'})
            print(CrystalOperations.transfer_conditions(self.test_graph_4))
            
    
    def test_process_condition(self):
        # No cross terms
        with self.subTest("Single"):
            self.assertEqual(CrystalOperations.process_condition(
                ['(c1)']),
                '(c1)')
        with self.subTest("No &"):
            self.assertEqual(CrystalOperations.process_condition(
                ['(c1|c2)']),
                '(c1)|(c2)')
        with self.subTest("No |"):
            self.assertEqual(CrystalOperations.process_condition(
                ['(c1)','(c2)','(c3)']),
                '(c1&c2&c3)')
        with self.subTest("Sorting |"):
            self.assertEqual(CrystalOperations.process_condition(
                ['(c1|c5|c3|c2|c4)']),
                '(c1)|(c2)|(c3)|(c4)|(c5)')
        with self.subTest("Sorting &"):
            self.assertEqual(CrystalOperations.process_condition(
                ['(c1)','(c5)','(c3)','(c2)','(c4)']),
                '(c1&c2&c3&c4&c5)')

        # Cross term cases element
        with self.subTest("Simple Generic"):
            self.assertEqual(CrystalOperations.process_condition(
                ['(c1|c2)', '(c1|c3)']),
                '(c1)|(c2&c3)')
        with self.subTest("Complex Generic"):
            self.assertEqual(CrystalOperations.process_condition(
                ['(c1|c2|c5)','(c2|c4|c3)','(c4|c5)','(c6|c4)']),
                '(c1&c4)|(c2&c4)|(c4&c5)|(c2&c5&c6)|(c3&c5&c6)')

        with self.subTest('Special Case'):
            self.assertEqual(CrystalOperations.process_condition(
                ['(c7|c5)', '(c7|c5|c4)', '(c7|c4|c3)', '(c7|c3|c2)', '(c7|c2|c1)', '(c7|c1)']), 
                '(c7)|(c1&c3&c5)|(c1&c2&c4&c5)')

        # Errors
        with self.subTest("Empty"):
            self.assertRaises(SyntaxError, CrystalOperations.process_condition,[''])
            

        
def test():
    unittest.main(verbosity=2, exit=False)
