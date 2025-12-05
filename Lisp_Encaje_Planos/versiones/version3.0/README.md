# LEEME - Encajar Planos v3.0

Vale, aquí tienes la versión 3 del lisp para encajar planos. 
Básicamente hace lo mismo que la v2, pero ahora te crea sola la capa "CapaPlanoaEncajar" para que quede todo ordenadito y no tengas que hacerlo tú a mano.

## De qué va esto
Es para coger un plano que está por ahí perdido (escalado, rotado, movido) y ponerlo en su sitio usando otro plano de referencia. 

## Cómo se usa
Sencillo, al lío:

1. **Carga el lisp**: Arrastra el archivo o usa `appload`.
2. **Ejecuta el comando**: Escribe `EncajarPlanos3` y dale a Intro.
3. **Paso 1 (El ORIGEN)**: Selecciona todo lo del plano BUENO (el que está bien puesto). Dale a intro. 
   - *Nota: El lisp se encarga de explotar bloques y ponerlo todo en su capa, tú ni te preocupes.*
4. **Paso 2 (EL QUE MUEVES)**: Selecciona el plano que quieres ENCAJAR (el que está mal). Dale a intro.
5. **Paso 3 (LOS PUNTOS)**: 
   - Pincha un punto en el plano *malo* (origen).
   - Pincha el mismo punto en el plano *bueno* (destino).
   - Repite para un segundo punto.
6. **Magia**: Se alineará, escalará y rotará solo.

Y ya estaría. Si falla algo, grita.
