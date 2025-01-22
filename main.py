# Este script forman parte del Trabajo de Fin de Grado de Álvaro Martín Martín
# (©2023). Distribuido bajo la licencia CC BY-SA 4.0.

from flask import Flask, request, jsonify
from pymongo import MongoClient
import argparse

class CustomArgumentParser(argparse.ArgumentParser):
    def error(self, message):
        if '-h' in message or '--help' in message:
            self.print_help()
        else:
            print(message)
            print('\nEl script no se ha ejecutado porque se deben introducir correctamente todos los parámetros: --mongoUrl, --db, y --collection.\n')
        exit(2)

coleccionesPermitidas = [
    "ColeccionesSeparadas", 
    "Taxon_Poblaciones-Registros", 
    "Poblacion_TaxonRegistros", 
    "Registro_TaxonPoblacion"
]

parser = CustomArgumentParser(description='Script para conectarse a MongoDB y cargar datos en una determinada colección de una base de datos.')
parser.add_argument('--mongo_url', required=True, help='URL de conexión a MongoDB')
parser.add_argument('--db', required=True, help='Nombre de la base de datos')
parser.add_argument('--collection', required=True, choices=coleccionesPermitidas, metavar='', help=f'\nNombre de la colección. OPCIONES PERMITIDAS --> {", ".join(coleccionesPermitidas)}')
args = parser.parse_args()

mongoUrl = args.mongo_url
nombreDb = args.db
nombreColeccionDefecto = args.collection

app = Flask(__name__)

cliente = MongoClient(mongoUrl)
db = cliente[nombreDb]

def limpiarDatos(datos):
    if isinstance(datos, dict):
        dictLimpio = {
            k: limpiarDatos(v) for k, v in datos.items()
            if k != "_row"
            and not (isinstance(v, list) and v == [])
            and v is not None
            and v != ""
        }
        return {k: v for k, v in dictLimpio.items() if v != {}}
    elif isinstance(datos, list):
        return [limpiarDatos(item) for item in datos]
    else:
        return datos

@app.route('/insert', methods=['POST'])
def insertarDocumento():
    datos = request.get_json(force=True)
    if datos is None:
        return jsonify({'Error': 'JSON inválido'}), 400
    
    if nombreColeccionDefecto == "ColeccionesSeparadas":
        if isinstance(datos, list) and len(datos) > 0 and isinstance(datos[0], dict):
            nombreColeccion = datos[0].get('nombreColeccion', None)
            if nombreColeccion is None:
                return jsonify({'error': 'No se proporcionó el nombre de la colección en los datos del JSON'}), 400
            for item in datos:
                item.pop('nombreColeccion', None)
        else:
            return jsonify({'Error': 'Formato inválido, se debe recibir un JSON'}), 400
    else:
        nombreColeccion = nombreColeccionDefecto
    
    coleccion = db[nombreColeccion]

    datosLimpios = limpiarDatos(datos)
    try:
        resultado = coleccion.insert_many(datosLimpios)
        return jsonify({'Estado': 'éxito', 'IDs insertados': [str(id) for id in resultado.inserted_ids]}), 201
    except Exception as e:
        return jsonify({'Error, algo inesperado ha ocurrido': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
