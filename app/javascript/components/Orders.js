import React, { useState } from 'react'
import { capitalize, filter, first, keys, last, map, sortBy, uniq, values } from 'lodash';

function validFromOptions(order, validOrder) {
  const requiresFrom = order.type === 'support' || order.type === 'convoy';
  return requiresFrom && sortBy(uniq(map(validOrder[order.type], detail => first(detail).id)));
}

function validToOptions(order, validOrder) {
  if (order.type === 'hold') {
    return null;
  }
  const orderDetails = validOrder[order.type];
  if (order.type === 'move') {
    return sortBy(map(orderDetails, detail => detail.id));
  }
  const validPaths = filter(orderDetails, detail => first(detail).id === order.from_id);
  return sortBy(uniq(map(validPaths, detail => last(detail).id)));
}

function OrderRow({ areas, order, position, updateOrders, validOrder }) {
  const fromOptions = validFromOptions(order, validOrder);
  const toOptions = validToOptions(order, validOrder);

  const handleChange = (event) => {
    const { name, value } = event.target;
    const updates = { [name]: name === 'type' ? value : parseInt(value, 10) };
    if (name === 'type') {
      updates['from_id'] = null;
    }
    if (name !== 'to_id') {
      updates['to_id'] = null
    }
    updateOrders(prevOrders => ({
      ...prevOrders,
      [order.id]: { ...prevOrders[order.id], ...updates }
    }));
  }

  return (
    <tr>
      <td>{capitalize(position.type)}</td>
      <td>{areas[position.area_id].name}</td>
      <td>
        <div className="select is-rounded is-small">
          <select value={order.type} name="type" onChange={handleChange}>
            {keys(validOrder).map(orderType =>
              <option key={orderType} value={orderType}>{orderType.toUpperCase()}</option>
            )}
          </select>
        </div>
      </td>
      <td>
        {fromOptions &&
          <div className="select is-small">
            <select className="select-region" value={order.from_id || ''} name="from_id" onChange={handleChange}>
              {!order.from_id && <option value="" disabled>---</option>}
              {fromOptions.map(fromId =>
                <option key={fromId} value={fromId}>{areas[fromId].name}</option>
              )}
            </select>
          </div>
        }
      </td>
      <td>
        {toOptions &&
          <div className="select is-small">
            <select className="select-region" value={order.to_id || ''} name="to_id" onChange={handleChange}>
              {!order.to_id && <option value="" disabled>---</option>}
              {toOptions.map(toId =>
                <option key={toId} value={toId}>{areas[toId].name}</option>
              )}
            </select>
          </div>
        }
      </td>
    </tr>
  );
}

export default function Orders(props) {
  const csrfToken = document.querySelector('[name=csrf-token]').content;
  const [ordersSubmitted, setOrdersSubmitted] = useState(props.user_game.state === 'confirmed');
  const [orders, updateOrders] = useState(props.orders);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const submitOrders = (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    fetch(`/games/${props.user_game.game_id}/orders`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({ orders }),
      credentials: 'same-origin',
    })
    .then(response => response.json())
    .then(json => {
      setLoading(false);
      setOrdersSubmitted(true);
    })
    .catch(error => {
      setLoading(false);
      setError(error);
    });
  }

  return (
    <>
      <h2 className="subtitle is-5 is-pulled-left">Orders</h2>
      <button
        className={`button is-primary is-pulled-right${loading ? ' is-loading' : ''}`}
        onClick={submitOrders}>
        { ordersSubmitted ? 'Resubmit' : 'Submit' }
      </button>
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th>Unit</th>
            <th>Territory</th>
            <th>Order</th>
            <th className="order-region-column">From</th>
            <th className="order-region-column">To</th>
          </tr>
        </thead>
        <tbody>
          {values(orders).map(order =>
            <OrderRow
              key={order.id}
              order={order}
              position={props.positions[order.position_id]}
              areas={props.areas}
              updateOrders={updateOrders}
              validOrder={props.valid_orders[order.position_id]}
            />
          )}
        </tbody>
      </table>
      {error && <div className="notification is-warning is-light">{'asdflkj'}</div>}
    </>
  );
}
