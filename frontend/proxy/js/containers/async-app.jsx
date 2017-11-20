import React, { Component } from 'react';
import { connect } from 'react-redux';
import {
    fetchLists
} from 'proxy/js/actions';
import Hosts from 'proxy/js/components/hosts';

class AsyncApp extends Component {
    componentDidMount() {
        const {dispatch} = this.props;

        dispatch(fetchLists());
    }

    render() {
        const {hosts, ports, keys} = this.props;

        return (
            <div className="container">
                <Hosts hosts={hosts}/>
                <div>
                    <h3>Ports</h3>
                    {ports.isFetching ? <p>Fetching...</p> : ''}
                    {Object.keys(ports.items).length === 0 ? <p>No results</p> : ''}
                </div>
                <div>
                    <h3>Keys</h3>
                    {keys.isFetching ? <p>Fetching...</p> : ''}
                    {Object.keys(keys.items).length === 0 ? <p>No results</p> : ''}
                </div>
            </div>
        );
    }
}

function mapStateToProps(state) {
    const {hosts, ports, keys} = state;

    return {
        hosts,
        ports,
        keys
    };
}

export default connect(mapStateToProps)(AsyncApp);
