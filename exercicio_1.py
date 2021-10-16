import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import multivariate_normal

# Definição da média
mean=np.array([0, 0])
# Num de pontos
N=8000

def exa():
    cov=np.matrix([[1, 0],[0, 1]])
    return cov

def exb():
    cov=np.matrix([[0.2, 0],[0, 0.2]])
    return cov

def exc():
    cov=np.matrix([[2, 0],[0, 2]])
    return cov

def exd():
    cov=np.matrix([[0.2, 0],[0, 2]])
    return cov

def exe():
    cov=np.matrix([[1, 0.5],[0.5, 1]])
    return cov

def exf():
    cov=np.matrix([[0.3, 0.5],[0.5, 2]])
    return cov

def exg():
    cov=np.matrix([[0.2, -0.5],[-0.5, 2]])
    return cov


def main(exercicio):
    # Pontos
    funcname = 'ex' + exercicio
    cov = eval(funcname + "()")
    x1, x2 = np.random.multivariate_normal(mean, cov, N).T

    plt.figure()
    plt.scatter(x1, x2, cmap='PING',alpha=0.3, color='green')
    plt.axis([-8, 8, -8, 8])
    plt.title("Scatter " + exercicio.upper())
    plt.show()

main('g')