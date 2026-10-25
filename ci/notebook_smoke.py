"""Exercise authenticated Lab startup and real Python/Julia notebook kernels."""

import os
import secrets
import socket
import subprocess
import sys
import tempfile
import time
from urllib.request import urlopen

import nbformat
from jupyter_client.kernelspec import KernelSpecManager
from nbclient import NotebookClient
from nbconvert import HTMLExporter


def execute(kernel, source):
    notebook = nbformat.v4.new_notebook(cells=[nbformat.v4.new_code_cell(source)])
    NotebookClient(notebook, kernel_name=kernel, timeout=180).execute()
    assert notebook.cells[0].execution_count == 1
    html, _ = HTMLExporter().from_notebook_node(notebook)
    assert "kernel-ok" in html


def main():
    execute(
        "python3",
        "import numpy as np, pandas as pd, scipy, sympy\n"
        "import matplotlib; matplotlib.use('Agg')\n"
        "import matplotlib.pyplot as plt\n"
        "from PIL import Image\nfrom io import BytesIO\n"
        "assert np.arange(3).sum() == 3\n"
        "from scipy.linalg import solve\n"
        "np.testing.assert_allclose(solve([[3., 1.], [1., 2.]], [9., 8.]), [2., 3.])\n"
        "assert pd.Series([1, 2]).sum() == 3\n"
        "out = BytesIO(); plt.plot([0, 1]); plt.savefig(out, format='png')\n"
        "out.seek(0); image = Image.open(out); image.load()\n"
        "assert image.width > 0\nprint('kernel-ok')",
    )
    kernels = KernelSpecManager().find_kernel_specs()
    julia = next(name for name in kernels if name.startswith("julia"))
    execute(julia, 'using LinearAlgebra; @assert sum([1, 2]) == 3; println("kernel-ok")')
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        port = sock.getsockname()[1]
    with tempfile.TemporaryDirectory() as root, tempfile.TemporaryFile() as log:
        env = dict(os.environ, JUPYTER_TOKEN=secrets.token_hex(24))
        process = subprocess.Popen(
            [
                sys.executable,
                "-m",
                "jupyterlab",
                "--no-browser",
                "--ip=127.0.0.1",
                f"--port={port}",
                "--ServerApp.port_retries=0",
                f"--ServerApp.root_dir={root}",
            ],
            env=env,
            stdout=log,
            stderr=log,
        )
        try:
            for _ in range(60):
                if process.poll() is not None:
                    raise RuntimeError("JupyterLab exited before readiness")
                try:
                    with urlopen(f"http://127.0.0.1:{port}/lab?token={env['JUPYTER_TOKEN']}", timeout=2) as response:
                        assert response.status == 200
                        assert b"jupyter" in response.read().lower()
                    break
                except OSError:
                    time.sleep(1)
            else:
                raise RuntimeError("JupyterLab did not become ready")
        finally:
            process.terminate()
            process.wait(timeout=15)


if __name__ == "__main__":
    main()
