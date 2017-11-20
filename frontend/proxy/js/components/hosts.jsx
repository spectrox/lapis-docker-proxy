import React from 'react';

export default class Hosts extends React.Component {
    render() {
        let {hosts} = this.props;

        return (
            <div>
                <h3>Hosts</h3>
                {hosts.isFetching ? <p>Fetching...</p> : ''}
                {Object.keys(hosts.items).length === 0 ? <p>No results</p> : ''}
            </div>
        );
    }
}
