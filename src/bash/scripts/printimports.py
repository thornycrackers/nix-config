"""Script for printing all of the imports of pyton file."""
import ast
import sys


class MyNodeVisitor(ast.NodeVisitor):
    """https://docs.python.org/3/library/ast.html#ast.NodeVisitor"""

    def __init__(self):
        self.imports = set()

    def visit_Import(self, node):
        for module_node in node.names:
            self.imports.add(f"import {module_node.name}")
        self.generic_visit(node)

    def visit_ImportFrom(self, node):
        module_name = node.module
        for from_node in node.names:
            self.imports.add(f"from {module_name} import {from_node.name}")
        self.generic_visit(node)


# Consider all arguments passed to be filepaths
for file_path in sys.argv[1:]:
    with open(file_path, "r") as f:
        contents = f.read()
        mod_ast = ast.parse(contents)
        visitor = MyNodeVisitor()
        visitor.visit(mod_ast)
        for import_line in visitor.imports:
            print(import_line)
