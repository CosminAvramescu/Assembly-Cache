cache.asm

	Initial, stabilesc tag-ul (edx) si offset-ul (esi) din adresa primita. Rotesc la dreapta
esi pentru a aduce in fata ultimii 3 octeti, apoi shiftez la dreapta cu 29 pentru a ramane in esi
acei 3 octeti rotiti. Shiftez la dreapta edx cu 3 pentru a ramane in edx doar tag-ul. Compar pe
rand tag-ul meu (edx) cu fiecarer tag din tags. Daca l-am gasit, salvez adresa lui reg in ebx,
fac eax sa devina 8*eax (de 3 ori add, din lipsa de registre goale), apoi adaug in eax offset-ul
(esi). Mut in valoarea de la adresa lui reg (ebx) ceea ce se gaseste in esi (cache[i][offset]). 
Functia check_find_loop vrifica daca s-au terminat de parcurs tag-urile. Am considerat ca sunt 100
de tag-uri deoarece sunt 100 de linii de cache, iar fiecare tag corespunde unei linii de cache.
Daca nu s-a gasit tag-ul, se duce tags pe tags[to_replace], se muta aici tag-ul edx, apoi se 
initializeaza cu 0 ultimii 3 biti din tag-ul edx. Se salveaza pe stiva valoarea lui esi (offset-ul),
pentru a elibera registrul esi. Se initializeaza cu 0 esi pentru a contoriza punerea celor 8 octeti
in cache. edi devine 8*edi si se intra in add_bytes_in_cache. Se salveaza intr-o variabila globala 
esi, se pune in esi fiecare octet in parte (edx+1, edx+2,...), se pune pe linia cache[to_replace]
cate un octet din esi (edx+1, edx+2,...). Se readuce valoarea initiala a lui esi inapoi din
variabila globala. Se incrementeaza edi si esi si se verifica daca s-au terminat de scris toti octetii.
La finalul adaugarii octetilor, se adauga in eax (la adresa lui reg), valoarea lui
cache[to_replace][offset]. Se readuce de pe stiva valoarea de la push a lui esi (offset-ul), se
reface edi ca fiind 8*edi si se adauga la el esi. Se salveaza la valoarea de la adresa lui reg
(eax) octetul dorit.