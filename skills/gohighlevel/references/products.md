# Products & Pricing API Reference

## Product Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/products?locationId={id}` | List products |
| POST | `/products` | Create product |
| GET | `/products/{productId}` | Get product |
| PUT | `/products/{productId}` | Update product |
| DELETE | `/products/{productId}` | Delete product |

## Price Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/products/{productId}/prices` | List prices for product |
| POST | `/products/{productId}/prices` | Create price |
| GET | `/products/{productId}/prices/{priceId}` | Get price |
| PUT | `/products/{productId}/prices/{priceId}` | Update price |
| DELETE | `/products/{productId}/prices/{priceId}` | Delete price |

## List Products

```
GET /products?locationId={locationId}
```

**Response:**
```json
{
  "products": [
    {
      "id": "product-id",
      "name": "Coaching Package",
      "description": "6-week coaching program",
      "locationId": "loc-id"
    }
  ]
}
```

## Create Product

```
POST /products
```
```json
{
  "locationId": "location-id",
  "name": "Coaching Package",
  "description": "6-week coaching program"
}
```

## Create Price for Product

```
POST /products/{productId}/prices
```
```json
{
  "amount": 99700,
  "currency": "USD",
  "billingCycle": "one-time"
}
```

**Billing cycle options:** `one-time`, `monthly`, `yearly`, `weekly`

**Note:** Amount is typically in cents (99700 = $997.00). Verify with the specific sub-account's currency settings.

## Typical Workflow

1. Create the product with name and description
2. Create one or more prices for that product (one-time, recurring, etc.)
3. Products can be linked to funnels, order forms, and invoices in GHL
