# -*- coding: utf-8 -*-
import pytest


@pytest.fixture
def calculate_mi_vars():
    from terraform import calculate_mi_vars
    return calculate_mi_vars


def mirror(item):
    def inner(*args, **kwargs):
        return item

    return inner


@pytest.mark.parametrize('role,serverstate',
                         [('control', True), ('worker', False),
                          ('none', False)])
def test_attrs(calculate_mi_vars, role, serverstate):
    mirrorer = mirror(('', {'role': role}, []))
    func = calculate_mi_vars(mirrorer)
    _, attrs, _ = func()
    assert 'consul_is_server' in attrs
    assert attrs['consul_is_server'] == serverstate


@pytest.mark.parametrize('routable', [True, False])
def test_publicly_routable(calculate_mi_vars, routable):
    attrs = {}
    if routable:
        attrs['publicly_routable'] = True

    mirrorer = mirror(('', attrs, []))
    func = calculate_mi_vars(mirrorer)
    _, _, groups = func()
    if routable:
        assert 'publicly_routable' in groups
    else:
        assert 'publicly_routable' not in groups
