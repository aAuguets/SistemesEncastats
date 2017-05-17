import math
import serial
import time

PORT= '/dev/cu.usbmodem1421'
BR=115200
bytesize=serial.EIGHTBITS
parity=serial.PARITY_NONE
stopbits=serial.STOPBITS_ONE
timeout= 10
serialport=serial.Serial(PORT,BR,bytesize,parity,stopbits,timeout)
samples= 205
s1=[0.,0.,0.,0.,0.,0.,0.,0.]
s2=[0.,0.,0.,0.,0.,0.,0.,0.]
estat = 0 #0 = espero dada, 1= espero silenci
freqs=[697,770,852,941,1209,1336,1477,1633]
#freqs=[1.,1.,1.,1.,1.,1.,1.,1.]
results=['1','2','3','A','4','5','6','B','7','8','9','C','*','0','#','D']
coeficients=[0.,0.,0.,0.,0.,0.,0.,0.]
LLINDAR= 1e6

def cacul_mostres(freqs):
    i=0
    lista=[]
    for element in freqs:
        coeficients[i]=2*math.cos(2*math.pi*(element/8000.*205.)/205.)
        i+=1
    return coeficients

def goertzel(coeficients):
    #s1=[0.,0.,0.,0.,0.,0.,0.,0.]
    #s2=[0.,0.,0.,0.,0.,0.,0.,0.]
    global s1,s2
    for i in range(0,8):
        s1[i]=0
        s2[i]=0

    values=serialport.read(205)
    x=0
    for element in values:
        if x==0:
            for i in range(0,8):
                s1[i]=ord(element)
                x+=1
        elif x==1:
            for i in range(0,8):
                s2[i]=ord(element)+coeficients[i]*s1[i]
                x+=1
        else :
            for i in range(0,8):
                s=ord(element) + (coeficients[i]*s1[i])-(s2[i])
                s2[i]=s1[i]
                s1[i]=s
                x+=1
#goertzel()
def calcul_potencia(s1,s2):
    potencies=[0.,0.,0.,0.,0.,0.,0.,0.]
    for i in range(0,8):
        potencies[i]= s1[i]**2 +s2[i]**2 - (coeficients[i]*s1[i])*s2[i]
    return potencies

def detecta_resultat(lista_potencias):
    d_fila=False
    d_columna=False
    trobat=0
    posicio=0
    for i in range(0,4):
        if lista_potencias[i] > LLINDAR:
            posicio +=i*4
            d_fila=True
            trobat+=1
            #break
    for i in range(4,8):
        if lista_potencias[i]>LLINDAR:
            posicio +=(i-4)
            d_columna=True
            trobat+=1
            #break
    if (d_columna and d_fila and trobat==2):
        return results[posicio]
    elif trobat > 0 :
        return '?'
    else:
        return '-'


def maquina_estats(value):
    global estat
    if estat == 0:
        if ((value != '-') and (value != '?')):
            print value
            estat = 1
        else:
            estat = 0
    elif estat == 1:
        if(value == '-'):
            estat = 0
        else:
            estat = 1




lista=cacul_mostres(freqs)
time.sleep(5)
while(1):
    t1 = time.time()
    goertzel(lista)
    maquina_estats(detecta_resultat(calcul_potencia(s1,s2)))
    print time.time() - t1
