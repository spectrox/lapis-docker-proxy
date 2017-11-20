import React from 'react';
import { render } from 'react-dom';
import Root from 'proxy/js/containers/root';

render(
    React.createElement(Root),
    document.getElementById('app')
);
