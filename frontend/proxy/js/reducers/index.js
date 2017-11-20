import { combineReducers } from 'redux';
import hosts from 'proxy/js/reducers/hosts';
import ports from 'proxy/js/reducers/ports';
import keys from 'proxy/js/reducers/keys';

const proxyApp = combineReducers({
    hosts,
    ports,
    keys
});

export default proxyApp;
