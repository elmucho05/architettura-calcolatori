# Procedure calling

Le procedure/funzioni permettono al programmatore di implementare il concetto di astrazione . 

Per l'esecuzione di una procedura, un programma deve eseguire i seguenti passi:

1. mettere i parametri in un luogo accessibile alla procedura

2. trasferire il controllo alla procedura

3. acquisire le risorse necessarie per l'esecuzione della procedura

4. eseguire il compito richiesto

5. mettere il risultato in un luogo accessibile al programma chiamante

6. restituire il controllo al punto d'origine, dato che la stessa procedura può essere chiamata varie volte in punti diversi del programma. 

RISC-V usa i registri nel seguente modo:

- x10 - x17 , otto registri argomento per il passaggio di parametri o la restituzione di valori calcolati.

- x1: un registro di ritorno per tornare al punto d'origine

### Jump and link *jal*

Il risc-v infatti offre  un'istruzione per le procedure chiamata **jump and link : jal**.

- esegue un salto a un dato indirizzo e salva allo stesso tempo in un registro **(x1)** l'indirizzo dell'istruzione successiva a quella di salto. 
  
  `jal x1, IndirizzoProcedura` : salta a IndirizzoProcedura e scrivi l'indirizzo di ritorno in x1

x1 è detto anche indirizzo di ritorno, perché viene creato un indirizzo o collegamento che punta alla posizione della chiamata, così da permettere alla procedura di tornare all'indirizzo corretto. L'indirizzo di ritorno è necessario perché *la funzione può essere chiamata in vari punti del programma.*

Come introdotto nel caso del Switch case, in particolare nella fase di "case", abbiamo anche l'istruzione **jalr** jump and link register. 

`jalr x0, 0(x1)`.

Quest'istruzione salta all'indirizzo memorizzato nel registro x1. 

**Funzionamento di jal e jalr**

Perciò il programma **chiamante**, mette i valori dei parametri da passare alla procedura nei registri x10-x17 e usa l'istruzione `jal x1, X`,per saltare alla procedura **X** detta ***chiamata***. 

- questa a sua volta esegue le operazioni richieste, memorizza i risultati negli stessi registri dei parametri x10-x17, e restituisce il controllo al chiamante con l'istruzione `jalr x0, 0(x1)` .

E' implicita la necessità di mantenere in un registro l'indirizzo dell'istruzione in esecuzione. Per ragioni storiche questo registro viene quasi sempre chiamato **program counter o PC**. 

L'istruzione `jal` in realtà salva **PC+4** nel registro destinazione designato (x1 di solito) per creare i collegamento all'indirizzo dell'istruzione successiva, predisponendo così il ritorno dalla procedura.

- l'istruzione `jal` può essere usata per eseguire un salto incondizionato usando x0 `jal x0, Etichetta`.

### Utilizzo di più registri

Supponiamo quindi che un compilatore abbia bisogno, all'interno di una procedura, di un numero di registri più grande rispetto agli 8 dati da x10 a x17 per il passaggio di parametri .

- una volta terminata la chiamata di funzione, i registri vanno ripristinati con il valore *precedente la chiamata*. 

*Questa infatti è la tipica situazione nella quale è necessario copiare il contenuto dei registri in memoria.*

La struttura ideal per copiare il contenuto dei registri è lo **stack** (coda lifo).

- lo stack ha bisogno del puntatore dell'ultimo elemento inserito di modo che possa sapere dire alla prossima procedura dove salvare i nuovi registri e alla fine di dire dove trovare l'ultimo vecchio. 

- In RISC-V il puntatore allo stack è il registro **x2** ed è detto **stack-pointer (sp)**. 

- Lo *stack-pointer* viene incrementato o decrementato di una parola doppia ogni volta che si toglie o si inserisce il contenuto di un registro. 

- **push** : inserimto di un dato nello stack

- **pop**: estrazione dallo stack. 

Per ragioni storiche lo stack cresce a partire da indirizzi di memoria alti verso indirizzi bassi. Questo significa che quando **vengono** **inseriti** **dei** valori nello stack, il valore dello **stack pointer diminuisce**, al contario, quando i **dati** sono **estratti**, il valore dello **stack pointer aumenta** riducendosi la dimensione dello stack. 

Come vegono suddivisi i registri:

Risc-V suddivide i registri temporanei in due numeri.

- **x5-x7 e x28-31**: registri temporanei che non sono salvati in caso di chiamata di una procedura

- **x8-x9** e **x18-x27** : registri da salvare il cui contenuto deve essere preservato in caso di chiamata a procedura, quindi *se vengono usati da una procedura, prima devi salvarci il contenuto*.

**Esempio: trasformare la funzione in C in assembly**.

Compilazione di una procedura C che non contiene chiamate ad altre procedure:

```c
long long int esempio_foglia(long long int g, long long int h, 
long long int i, long long int j )
{
    long long int f;
    f = (g+h) - (i+j);
    return f;
}
```

Scriviamo l'opportuno codice assembler RISC-V:

Innanzitutto notiamo che la funzione contiene dei parametri quindi essi andranno salvati in dei registri temporanei. 

`g,h,i,j` li metteremo in `x10,x11,x12,x13` mentre `f` andrà in `x20`. Il programma inizia con l'etichetta della procedura:

L'assegnamento all'interno della procedura : `f = (g+h) - (i+j)h` è una store che utilizza 3 registri dove mette il risultato di g+h, i+j e infine f, essi sono **x5,x6,x20**.

Quindi dopo aver allocato loro lo spazio, devo salvare il contenuto di questi registri nello stack(push):

```risc-v
esempio_foglia:
    addi sp, sp, -24 //aggiornamento dello stackpointer per far posto a 3 elemnti
    //devo salvare 3 elementi da 8 byte, 8*3=24, stack diminusice
    //ora devo creare i registri per g+h, i+j ed f
    sd x5, 16(sp)
    sd x6, 8(sp)
    sd x20,0(sp) 
```

Spiegazione:

- Devi salvare 3 registri da 8 byte perché sono long long int, quindi nello stack che diminuisce verso il basso devi salvare 8*3=24 byte.

- Dopodiche devi salvare g+h, il che se consideri lo stack pointer il primo valore quindi f, deve essere messo sotto di poiché : *in 0 salvi x20 quindi f*, e questo vuole 8 byte. Quindi il prossimo disponibile sarà a 8byte, ma là salvi i+j che vuole altri 8, per cui il primo indirizzo disponibile è 16 byte fino a 24

- salvi ora i+j, a 8 byte dallo stackpoint

- infine salvi f a 0byte, ricordandoti che vuole 8 byte.



Ora *facciamo i calcoli all'interno della funzione*:

```risc-v
add x5, x10, x11 //x5 contiene g+h
add x6, x12, x13 //x6 contiene i+j
sub x20, x5, x6 //f = x65-x6
```

Per poter **restituire f** bisogna copiarlo in un registro di parametri:

`addi x10, x20, 0` : fa x10 = x20 + 0



Prima del ritorno al programma chiamante, il vecchio valore dei registri va ripristinato, copiandolo **quindi facendo una pop** dallo stack:

```risc-v
ld x20, 0(sp)
ld x6, 8(sp)
ld x5, 16(sp)
addi sp, sp, 24 //eleminazione di 3 elementi
```

La procedura terminal con un'istruzione di salto a registro, usando l'indirizzo di ritorno:

`jalr x0, 0(x1)`.



### Procedure annidate

Le procedure che non chiamano altre procedure sono chiamate procedure *foglia*.

Esempio: se il programma principale chiama una procedura A passandoci il valore di 3 che viene salvato in x10, a sua volta la procedura A può chiamare una procedura B passandoci il valore 7 che a sua volta andrà nel registro x10. C'è quindi un conflitto nell'uso di x10 e in modo analogo si verifica un conflitto nell'indirizzo di ritorno di B.

- se non affrontiamo delle contromisure, si farebbe in modo che la procedura A non sia più in grado di trasferire il controllo al suo chiamante.



*Soluzione*

Salvare nello stack tutti i registri il cui contenuto deve essere salvato. 

- Il programma chiamante salverà quindi nello stack qualunque registro argomento (*x10-x17*) o registro temporaneo (*x5-x7 e x28-x31*) quando gli servirà il contenuto di questi dopo la chiamata

- Il programma chiamato salverà nello stack il registro di ritorno *x1*, e gli altri registri da preservare, quindi *x8-x9 e x18-27* di cui ha bisogno. 

- Lo stack pointer *sp* sarà aggiornato per tenere conto del numero di registri da memorizzare nello stack, al termine della procedura il contenuto dei registri va repristinato con il contenuto nello stack e lo *sp* andrà repristinato.



Esempio: **compilazione id una procedura ricorsiva come procedure annidate**

```c
long long int fatt(long long int n)
{
    if (n<1) return (1);
    else return (n* fatt(n-1);
}
```

Costruiamo il codice assembler RISC-V:

Il parametro *n* corrisponde al registro argomento *x10*. Il programma quindi inizia con l'etichetta della procedura seguita dal salvataggio sullo stack di due registri: x10 e quello di ritorno, ricordandoci *che lo stack cresce verso il basso*:

```risc-v
fatt:
    addi sp, sp, -16 //2 elementi da 8
    sd x1, 8(sp)
    sd x10, 0(sp)
```

Adesso consideriamo il caso della chiamata per la prima volta di *fatt*. L'istruzione sd, salva quindi sullo stack l'indirizzo del programma chiamante. Le istruzioni successive sono quella di *if n<1 e n>= 1*, la procedura*salta a L1*

```risc-v
addi x5, x10, 1 //x5 = n-1
bge  x5, x0, L1 //se (n-1)>=0, salta a L1
```

Se invece *n<1* , fattoriale restituisce il valore 1 mettendolo in un registro valore: somma 1 a 0 e memorizza il risultato in x10. Elimina quindi dallo stack i due registri e salta a quello di ritorno:

```risc-v
addi x10,x0, 1 // restituisci 1 (if (n<1) return 1)
addi sp, sp, 16 // elimina 2 elementi dallo stack e ritorna al chiamante
jalr x0, 0(x1) //ritorna al chiamante
```

Se n>1, quindi devo fare l'else:

il parametro *n* viene decrementato  e viene chiamata di nuovo la procedura fattoriale passandole il nuovo valore

```risc-v
L1: addi x10, x10, -1 //else, l'argomento diventa n-1, fatt(n-1)
jal x1, fatt //chiama fatt(n-1)
```



L'istruzione successiva è quella che la procedura fattoriale ritorna al termine della sua esecuzione, il risultato si trova in *x10*. Occorre quindi ripristinare il vecchio indirizzo di ritorno e il vecchio valore del parametro e lo stack pointer:

```risc-v
addi x6, x10, 0 // ritorno da jal, sposa il risulatato di fatt(n-1) in x6
ld x10, 0(sp)
ld x1, 8(sp)
addi sp, sp, 16
```

Successiavmente nel registro argomento x10 viene memorizzato il prodotto del vecchio argomento con il risultato di fatt(n-1) contenuto in x6. Supponiamo di avere a disposizione un'istruzione per la moltiplicazione:

`mul x10, x10, x6` //restituisce n* fatt(n-1)

Infine la procedura *fatt* salta all'indirizzo di ritorno:

`jalr x0, 0(x1)` //ritorna al chiamante.



Codice c:

```c
long long int fatt(long long int n)
{
    if (n<1) return (1);
    else return (n* fatt(n-1);
}
```

Codice completo:

```risc-v
fatt:
    addi sp, sp, -16
    sd x1, 8(sp)//salvo l'indirizzo di ritorno
    sd x10,0(sp) //salvo il parametro nello stack (n)
    //caso base, n<0, restituisco 1
    addi x5, x10-1 // salvo n-1 in x5
    bge x5, x0, L1 //se n-1 >= 0 allora salta a L1
    addi x10, x0, 1 //else return 1, 0+1
    addi sp, sp, 16 // togli dallo stack
    jalr x0, 0(x1)  //ritorna al chiamante
L1: //caso ricorsivo
    //restituisco n*fatt(n-1)
    //faccio prima fatt(n-1)
    addi x10, x10, -1 //sono nel caso ricorsivo, n diventa n-1, chiamo fatt(n-1)
    jal x1, fatt //fai chiama fatt(n-1)
    //ora sei nel caso ricorsivo
    addi x6, x10, 0 //salva il risultato di fatt(n-1) in x6
    ld x10, 0(sp) //ripristina il valore nello stack
    ld x1, 8(sp) //ripristina il registro di ritorno
    add sp, sp, 16 //svuota lo stack
    mul x10, x10, x6 //n* fatt(n-1)
    jalr x0, 0(x1)//ritorna al chiamante
```


