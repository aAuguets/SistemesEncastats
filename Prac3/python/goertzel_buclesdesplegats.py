
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
    s1[0]=0
    s2[0]=0

    s1[1]=0
    s2[1]=0

    s1[2]=0
    s2[2]=0

    s1[3]=0
    s2[3]=0

    s1[4]=0
    s2[4]=0

    s1[5]=0
    s2[5]=0

    s1[6]=0
    s2[6]=0

    s1[7]=0
    s2[7]=0

    values=serialport.read(205)
    i=0
    for element in values:
        if i==0:
            s1[0]=ord(element)
            s1[1]=ord(element)
            s1[2]=ord(element)
            s1[3]=ord(element)
            s1[4]=ord(element)
            s1[5]=ord(element)
            s1[6]=ord(element)
            s1[7]=ord(element)
            i+=1
        elif i==1:
            s2[0]=ord(element)+coeficients[0]*s1[0]
            s2[1]=ord(element)+coeficients[1]*s1[1]
            s2[2]=ord(element)+coeficients[2]*s1[2]
            s2[3]=ord(element)+coeficients[3]*s1[3]
            s2[4]=ord(element)+coeficients[4]*s1[4]
            s2[5]=ord(element)+coeficients[5]*s1[5]
            s2[6]=ord(element)+coeficients[6]*s1[6]
            s2[7]=ord(element)+coeficients[7]*s1[7]
            i+=1
        else :
            s=ord(element) + (coeficients[0]*s1[0])-(s2[0])
            s2[0]=s1[0]
            s1[0]=s

            s=ord(element) + (coeficients[1]*s1[1])-(s2[1])
            s2[1]=s1[1]
            s1[1]=s

            s=ord(element) + (coeficients[2]*s1[2])-(s2[2])
            s2[2]=s1[2]
            s1[2]=s

            s=ord(element) + (coeficients[3]*s1[3])-(s2[3])
            s2[3]=s1[3]
            s1[3]=s

            s=ord(element) + (coeficients[4]*s1[4])-(s2[4])
            s2[4]=s1[4]
            s1[4]=s

            s=ord(element) + (coeficients[5]*s1[5])-(s2[5])
            s2[5]=s1[5]
            s1[5]=s

            s=ord(element) + (coeficients[6]*s1[6])-(s2[6])
            s2[6]=s1[6]
            s1[6]=s

            s=ord(element) + (coeficients[7]*s1[7])-(s2[7])
            s2[7]=s1[7]
            s1[7]=s
            i+=1
#goertzel()
def calcul_potencia(s1,s2):
    potencies=[0.,0.,0.,0.,0.,0.,0.,0.]
    potencies[0]= s1[0]**2 +s2[0]**2 - (coeficients[0]*s1[0])*s2[0]
    potencies[1]= s1[1]**2 +s2[1]**2 - (coeficients[1]*s1[1])*s2[1]
    potencies[2]= s1[2]**2 +s2[2]**2 - (coeficients[2]*s1[2])*s2[2]
    potencies[3]= s1[3]**2 +s2[3]**2 - (coeficients[3]*s1[3])*s2[3]
    potencies[4]= s1[4]**2 +s2[4]**2 - (coeficients[4]*s1[4])*s2[4]
    potencies[5]= s1[5]**2 +s2[5]**2 - (coeficients[5]*s1[5])*s2[5]
    potencies[6]= s1[6]**2 +s2[6]**2 - (coeficients[6]*s1[6])*s2[6]
    potencies[7]= s1[7]**2 +s2[7]**2 - (coeficients[7]*s1[7])*s2[7]
    return potencies

def detecta_resultat(lista_potencias):
    d_fila=False
    d_columna=False
    trobat=0
    posicio=0
    if lista_potencias[0] > LLINDAR:
        posicio +=0*4
        d_fila=True
        trobat+=1
        #break
    if lista_potencias[1] > LLINDAR:
        posicio +=1*4
        d_fila=True
        trobat+=1
        #break
    if lista_potencias[2] > LLINDAR:
        posicio +=2*4
        d_fila=True
        trobat+=1
        #break
    if lista_potencias[3] > LLINDAR:
        posicio +=3*4
        d_fila=True
        trobat+=1
        #break

    if lista_potencias[4]>LLINDAR:
        posicio +=(4-4)
        d_columna=True
        trobat+=1
    if lista_potencias[5]>LLINDAR:
        posicio +=(5-4)
        d_columna=True
        trobat+=1
    if lista_potencias[6]>LLINDAR:
        posicio +=(6-4)
        d_columna=True
        trobat+=1
    if lista_potencias[7]>LLINDAR:
        posicio +=(7-4)
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
print "ready"
while(1):
    t1= time.time()
    goertzel(lista)
    maquina_estats(detecta_resultat(calcul_potencia(s1,s2)))
    print time.time() - t1
