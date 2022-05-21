let stripe, customer, price, card

export const InitCheckout = {
  mounted() {
    const paymentMethodCreatedCallback = paymentMethod => {
      this.pushEvent('payment-method-created', paymentMethod)
    }

    const isLoading = loadingState => {
      this.pushEvent('is-loading', { loading: loadingState })
    }

    init(this.el, { paymentMethodCreatedCallback, isLoading })

    this.handleEvent('requires_action', data => {
      requireCustomerAction({ clientSecret: data.client_secret, paymentMethodId: data.payment_method_id, isLoading: isLoading })
    })
  }
}

const init = (form, { paymentMethodCreatedCallback, isLoading }) => {
  stripe = Stripe(form.dataset.publicKey)
  let elements = stripe.elements()
  card = elements.create('card', { style: style })

  card.mount('#card-element')

  card.on('change', event => {
    displayError(event)
  })

  card.on('focus', event => {
    displayError(event)
  })

  // Handle form submission.
  form.addEventListener('submit', event => {
    event.preventDefault()
    isLoading(true)
    createPaymentMethod({ card, paymentMethodCreatedCallback, isLoading })
  })
}

function createPaymentMethod({ card, paymentMethodCreatedCallback, isLoading }) {
  const billingName = document.querySelector('#card-name').value

  stripe
    .createPaymentMethod({
      type: 'card',
      card: card,
      billing_details: {
        name: billingName
      }
    })
    .then(result => {
      if (result.error) {
        isLoading(false)
        displayError(result)
      } else {
        paymentMethodCreatedCallback(result.paymentMethod)
      }
    })
}

const requireCustomerAction = ({ clientSecret, paymentMethodId, isLoading }) => {
  stripe.confirmCardPayment(clientSecret, { payment_method: paymentMethodId }).then(result => {
    isLoading(false)

    if (result.error) {
      // start code flow to handle updating the payment details
      // Display error message in your UI.
      // The card was declined (i.e. insufficient funds, card has expired, etc)
      throw result
    }
  })
}

const displayError = event => {
  const displayError = document.getElementById('card-errors')
  if (event.error) {
    displayError.textContent = event.error.message
  } else {
    displayError.textContent = ''
  }
}

// Custom styling can be passed to options when creating an Element.
// (Note that this demo uses a wider set of styles than the guide below.)
const style = {
  base: {
    color: '#32325d',
    fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
    fontSmoothing: 'antialiased',
    fontSize: '16px',
    '::placeholder': {
      color: '#aab7c4'
    }
  },
  invalid: {
    color: '#fa755a',
    iconColor: '#fa755a'
  }
}
