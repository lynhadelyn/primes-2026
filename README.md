# Schur Partitions
A joint project by Vixail Hadelyn, Weiyou Li, Wenhui Li, Harper Niergarth, Rohith Thomas, Katherine Tung.

Previous work by:
+ Rohith Thomas & Katherine Tung at https://ecajournal.haifa.ac.il/Volume2027/ECA2027_S2A4.pdf
+ Vixail Hadelyn, Harper Niergarth, Weiyou Li, and Wenhui Li at https://arxiv.org/pdf/2606.00420


## Accessing crystal_graphs environment (untested)
First make sure you have conda installed. If you do then running the following will give you the current version
>conda --version

Download this repository and change your working directory to "*/primes-2026/lib/crystal_graphs". Choose your environment name and in your code editor run
>conda env create --name environment_name --file="environments.yml"

This will create a new anaconda environment and install the required dependencies. You should be able to run
>conda activate environment_name
>
>sage
>>attach("crystals.sage")

Now if everything went smoothly you can run commands from the "crystals.sage" interface. Try the following in sage to test if it works.
>>view(graphs.PetersenGraph())
>>
>>view(digraphs.ButterflyGraph(1))
>>
>>render([2,1],3)
>>
>>render([1,1],8,null_edges=[1,7],option='-A')

Try rendering with different options, or looking at the docstring by using render?
