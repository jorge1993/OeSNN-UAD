"""
SatNOGS Decoder subpackage initialization
"""
from __future__ import absolute_import, division, print_function

import functools
import re

from .aausat4 import Aausat4
from .acrux1 import Acrux1
from .alsat1n import Alsat1n
from .amicalsat import Amicalsat
from .armadillo import Armadillo
from .ascii85test import Ascii85test
from .asuphoenix import Asuphoenix
from .ax25frames import Ax25frames
from .ax25monitor import Ax25monitor
from .bdsat import Bdsat
from .bisonsat import Bisonsat
from .bobcat1 import Bobcat1
from .bugsat1 import Bugsat1
from .cape1 import Cape1
from .cas4 import Cas4
from .cas9 import Cas9
from .chomptt import Chomptt
from .connectat11 import Connectat11
from .csim import Csim
from .ctim import Ctim
from .cubebel1 import Cubebel1
from .cubesatsim import Cubesatsim
from .cute import Cute
from .delfin3xt import Delfin3xt
from .delfipq import Delfipq
from .dhabisat import Dhabisat
from .diy1 import Diy1
from .duchifat3 import Duchifat3
from .elfin import Elfin
from .entrysat import Entrysat
from .equisat import Equisat
from .eshail2 import Eshail2
from .foresail1 import Foresail1
from .fox import Fox
from .gaspacs import Gaspacs
from .grbalpha import Grbalpha
from .grizu263a import Grizu263a
from .gt1 import Gt1
from .inspiresat1 import Inspiresat1
from .irazu import Irazu
from .irvine import Irvine
from .iss import Iss
from .ksu import Ksu
from .ledsat import Ledsat
from .lightsail2 import Lightsail2
from .meznsat import Meznsat
from .minxss import Minxss
from .mirsat1 import Mirsat1
from .mitee1 import Mitee1
from .mxl import Mxl
from .mysat import Mysat
from .netsat import Netsat
from .neutron1 import Neutron1
from .opssat1 import Opssat1
from .oresat0 import Oresat0
from .origamisat1 import Origamisat1
from .painani import Painani
from .picsat import Picsat
from .planetum1 import Planetum1
from .polyitan1 import Polyitan1
from .pwsat2 import Pwsat2
from .qarman import Qarman
from .qbee import Qbee
from .qubik import Qubik
from .quetzal1 import Quetzal1
from .ramsat import Ramsat
from .salsat import Salsat
from .sanosat1 import Sanosat1
from .selfiesat import Selfiesat
from .siriussat import Siriussat
from .skcube import Skcube
from .spoc import Spoc
from .strand import Strand
from .targit import Targit
from .us6 import Us6
from .uwe4 import Uwe4
from .vzlusat2 import Vzlusat2

__all__ = [
    'Aausat4',
    'Acrux1',
    'Alsat1n',
    'Amicalsat',
    'Armadillo',
    'Ascii85test',
    'Asuphoenix',
    'Ax25frames',
    'Ax25monitor',
    'Bdsat',
    'Bisonsat',
    'Bobcat1',
    'Bugsat1',
    'Cape1',
    'Cas4',
    'Cas9',
    'Chomptt',
    'Connectat11',
    'Cubebel1',
    'Cubesatsim',
    'Cute',
    'Csim',
    'Ctim',
    'Delfin3xt',
    'Delfipq',
    'Dhabisat',
    'Diy1',
    'Duchifat3',
    'Elfin',
    'Entrysat',
    'Eshail2',
    'Equisat',
    'Foresail1',
    'Fox',
    'Gaspacs',
    'Grbalpha',
    'Grizu263a',
    'Gt1',
    'Inspiresat1',
    'Irazu',
    'Irvine',
    'Iss',
    'Ksu',
    'Ledsat',
    'Lightsail2',
    'Meznsat',
    'Minxss',
    'Mitee1',
    'Mirsat1',
    'Mxl',
    'Mysat',
    'Netsat',
    'Neutron1',
    'Opssat1',
    'Oresat0',
    'Origamisat1',
    'Painani',
    'Picsat',
    'Planetum1',
    'Polyitan1',
    'Pwsat2',
    'Qarman',
    'Qbee',
    'Qubik',
    'Quetzal1',
    'Ramsat',
    'Salsat',
    'Sanosat1',
    'Selfiesat',
    'Siriussat',
    'Skcube',
    'Spoc',
    'Strand',
    'Targit',
    'Us6',
    'Uwe4',
    'Vzlusat2',
]

FIELD_REGEX = re.compile(
    r':field (?P<field>[\*\w]+): (?P<attribute>.*?)'
    r'(?:(?=:field)|\Z|\n)', re.S)


def get_fields(struct, empty=False):
    """
    Get fields defined in docstring
    """
    fields = {}

    try:
        doc_fields = FIELD_REGEX.findall(struct.__doc__)
    except TypeError:
        return fields

    for key, value in doc_fields:
        try:
            fields[key] = functools.reduce(getattr, value.split('.'), struct)
        except AttributeError:
            if empty:
                fields[key] = None

    return fields
