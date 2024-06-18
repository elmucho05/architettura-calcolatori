Avendo una DRAM molto grande, nell'ordine dei giga. La cache di primo livello è di norma molto più piccola.
Sorge il problema di dire come fare in modo che i 32kb della cache L1 ,rappresentino l'insieme della DRAM che effettivamente il programma sta andando a richiedere.
Ci possiamo immaginare la DRAM partizionata in tanti blocchi di dimensioni compatibili con quelle della cache.

Sfruttiamo i principi di località:

**Località temporale**
Tanti anni di studio, ci hanno insegnato che se un programma usa un dato, probabilmente, lo userà di nuovo. 
Dato un certo indirizzo, probabilmente si ripeterà in sequenza nel tempo

**Località spaziale**
Se faccio accesso ad un indirizzo, probabilmente farò accesso anche a quelli vicini. Mi sposto di istante in istante ad un indirizzo successivo.

Ottengo così insiemi di segmenti e posso pensare di progettare un pezzo di memoria grande da ospitare questi pezzi e se il programma cicla su quegli indirizzi, in futuro ce li avrò già caricati in memoria. 


Livelli della gerarchia della memoria.
**Hit**
Quando carichiamo un programma in memoria, il codice va nella porzione di DRAM che è la Instruction Memory e i Dati nella Data Memory(che può essere anche disco fisico).

Devo attraversare la mia gerarchia di memoria per tornare al processore.

SE il dato che cerco non si trova nel livello dove lo sto cercando, faccio una **miss**.
Quando accendo il computer, la cache è vuota, **cold cache miss** e devo andare per forza a cercarlo in memoria.
Una miss comporta anche la gestione, cioè devo stallare il processore e dirgli di aspettare finché non l'ho preso.

Se il dato mi serve in L1, lo porto anche in L2. 
Quindi abbiamo un trade-off in termini di costi di produzione e area tra la DRAM e SRAM. 


*Perché la DRAM è più lenta della SRAM*
Teniamo i dati in dei condensatori/capacitor che tengono della carica. La DRAM ha bisogno di essere rinfrescata, per mantenere il dato lo leggo e scrivo. 
La memoria funziona a **banchi**. 
Ognuno di essi è una sorta di matrice righe per colonne. La DRAM funziona a righe, ho un costo grande per aprire una riga, dare una carica per leggere i dati.
Il costo per aprire una riga è alto, ma una volta fatto, per *accede ad una colonna* i tempi si abbattono.

Normalmente si cerca di sfruttare la modalità di accesso a **burst** --> cerco di leggere più colonne possibili, di modo che non devo aprire tante righe. Pago il costo per aprire, ma poi mi porto ai livelli sopra dei burst, ciclo per ciclo mi porto sopra un burst.
Le cache sono progettate per operare con più di una word alla volta, dipende da quanto è lunga la linea di cache.
I bursti sono blocchi di dati. Si implementano dei *row buffer* che sono dei modi per memorizzare l'intera riga.

**DDR** --> **double data rate** 
Oltre a parallelizzare sui fronti, parallelizza anche su input e output. Ha porte separate per l'input e output.

Il **Row Buffer** è un pezzo di memoria *non dram* che può tenera un'intera riga. Il caso tipico è che i programmi ha una regolarità col leggere i programmi. E' una sorta di cache, se sono fortunato, il programma mi chiederà dati che ho già nel row buffer.
Se sono sfortunato, dovrò cercare in una riga diversa. 

Anche il concetto di banking è uno di parallelismo, questo mi permette di aumentare il parallelismo del sistema. Si traduce in una maggiore **banda** che è la quantità di memoria che riesco a trasferire dalla DRAM verso il processore. 

Il concetto di **banking** è quindi di parallelismo. Dentro il mio sistema posso avere molti fattori che vogliono scrivere in DRAM. Questo significa che in generale, in ogni istante, posso avere più accessi alla DRAM. Se tanti elementi fanno richieste in *banchi diversi* posso gestire **tutte le richieste nello stesso ciclo**
- caso sfortunato se tutte le richieste mi capitano nello stesso banco/cella.

