"""Compatibility checks for the security-updated notebook toolchain."""

import ssl

import certifi
import mistune
import nbformat
from nbconvert import HTMLExporter, MarkdownExporter


def test_notebook_exporters():
    notebook = nbformat.v4.new_notebook(cells=[nbformat.v4.new_markdown_cell("# Security update\n\n**works**")])
    html, _ = HTMLExporter().from_notebook_node(notebook)
    markdown, _ = MarkdownExporter().from_notebook_node(notebook)
    assert "Security update" in html
    assert "**works**" in markdown


def test_markdown_emphasis_and_certificates():
    assert "<strong>works</strong>" in mistune.html("**works**")
    assert isinstance(mistune.html("*" * 1000 + "text" + "*" * 1000), str)
    context = ssl.create_default_context(cafile=certifi.where())
    assert context.cert_store_stats()["x509_ca"] > 0
