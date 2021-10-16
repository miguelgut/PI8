import pylab as pl
import numpy as np

# Retorna os pontos
def getPontos():
	global x1,x2,x3
	x = {
		1: np.array([0.1, 0.4, 0.1]),
		2: np.array([0.2, 0.5, 0.2]),
		3: np.array([0.1, 0.5, 0.1])	
	}

	# Transposta dos pontos
	x1 = x[1].reshape(-1, 1)
	x2 = x[2].reshape(-1, 1)
	x3 = x[3].reshape(-1, 1)

# Calcula a transposta da média
def getMedia():
	global me1,me2
	# Médias
	me = {
		1: np.array([0.,0.,0.]),
		2: np.array([0.5, 0.5, 0.5])
	}

	me1 = me[1].reshape(-1, 1)
	me2 = me[2].reshape(-1, 1)

# Calcula a covariância
def getCovariancia():
	global cov, covd
	_cov = np.matrix([
			[0.8,0.01,0.01],
			[0.01,0.2,0.01],
			[0.01,0.01,0.2]
	])
	# Matriz de Covariância
	cov = np.linalg.inv(_cov)

	# Matriz Diagonal da Matriz de Covariância
	temp = np.zeros((3, 3))
	np.fill_diagonal(temp, _cov.diagonal())
	covd = np.linalg.inv(temp)

# Subtração do Xs com a média 1:
def getCalcSubMedia1():
	global pontos_media_1, pontos_media_1_T
	pontos_media_1 = {
		1: np.subtract(x1,me1),
		2: np.subtract(x2,me1),
		3: np.subtract(x3,me1)
	}

	# transposta da subtração dos Xs com a média 1:
	pontos_media_1_T = {
		1: pontos_media_1[1].T, 
		2: pontos_media_1[2].T, 
		3: pontos_media_1[3].T 
	}

# Subtração dos Xs com a média 2:
def getCalcSubMedia2():
	global pontos_media_2, pontos_media_2_T

	pontos_media_2 = {
		1: np.subtract(x1,me2),
		2: np.subtract(x2,me2),
		3: np.subtract(x3,me2)
	}

	# transposta da subtração dos Xs com a média 2:
	pontos_media_2_T = {
		1: pontos_media_2[1].T, 
		2: pontos_media_2[2].T, 
		3: pontos_media_2[3].T 
	}

# Cálculo da Euclidiana
def euclidiana():
	print("Mínima distância euclidiana para a média 1:")
	for i in range(1, len(pontos_media_1) + 1):
		ai = pontos_media_1[i]
		ait = pontos_media_1_T[i]

		di = abs(np.dot(ait,covd))
		di = abs(np.dot(di,ai))
		dmi = np.sqrt(di)
		print("Ponto " + str(i) + str(dmi))

	print("\nMínima distância euclidiana para a média 2:")	
	for i in range(1, len(pontos_media_2) + 1):
		ai = pontos_media_2[i]
		ait = pontos_media_2_T[i]

		di = np.dot(ait,covd)
		di = np.dot(di,ai)
		dmi = np.sqrt(di)
		print("Ponto " + str(i) + str(dmi))

# Cálculo da Mahalanobis
def mahalanobis():
	print("\nMínima distância Mahalanobis para a média 1:")
	for i in range(1, len(pontos_media_1) + 1):
		ai = pontos_media_1[i]
		ait = pontos_media_1_T[i]

		di = np.dot(ait,cov)
		di = np.dot(di,ai)
		dmi = np.sqrt(di)
		print("Ponto " + str(i) + str(dmi))

	print("\nMínima distância Mahalanobis para a média 2:")
	for i in range(1, len(pontos_media_2) + 1):
		ai = pontos_media_2[i]
		ait = pontos_media_2_T[i]

		di = np.dot(ait,cov)
		di = np.dot(di,ai)
		dmi = np.sqrt(di)
		print("Ponto " + str(i) + str(dmi))

def init():
	getPontos()
	getMedia()
	getCovariancia()
	getCalcSubMedia1()
	getCalcSubMedia2()

def calc():
	euclidiana()
	mahalanobis()

if __name__== '__main__':
	init()
	calc()