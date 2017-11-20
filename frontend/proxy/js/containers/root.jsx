import React, { Component } from 'react';
import { Provider } from 'react-redux';
import configureStore from 'proxy/js/configure-store';
import AsyncApp from 'proxy/js/containers/async-app';

const store = configureStore();

export default class Root extends Component {
    render() {
        return (
            <Provider store={store}>
                <AsyncApp/>
            </Provider>
        );
    }
}
