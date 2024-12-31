;; EcoTokens Smart Contract - Green Energy Incentive Marketplace
;; This contract enables the creation and management of EcoTokens, a tokenized incentive system designed to promote the purchase and sale of green energy. 
;; It includes features such as setting token prices, transaction fees, energy reserve management, and listing energy for sale by users. 
;; Admins can adjust prices, caps, and fees, while users can list energy, purchase energy, and receive refunds based on conditions. 
;; The contract also ensures a transparent and fair market by enforcing rules such as token balance checks and energy reserve limits.
;; This system aims to encourage sustainable energy use through token-based incentives and marketplace operations.

;; Define constants for error codes and limits
(define-constant admin tx-sender)
(define-constant err-insufficient-tokens (err u200))
(define-constant err-transfer-failed (err u201))
(define-constant err-invalid-amount (err u202))
(define-constant err-unauthorized (err u203))
(define-constant err-price-too-low (err u204))
(define-constant err-fee-exceeds-limit (err u205))
(define-constant err-max-reserve-exceeded (err u206))
(define-constant err-not-enough-balance (err u207))

;; Define data variables
(define-data-var eco-token-price uint u50) ;; Price per EcoToken in microstacks (1 STX = 1,000,000 microstacks)
(define-data-var user-energy-cap uint u5000) ;; Maximum energy per user in kWh
(define-data-var transaction-fee uint u5) ;; Transaction fee percentage (e.g., 5 means 5%)
(define-data-var refund-percentage uint u80) ;; Refund percentage on transaction (e.g., 80 means 80% of the amount)
(define-data-var total-energy-reserve uint u0) ;; Total energy reserve in the marketplace (in kWh)
(define-data-var energy-reserve-cap uint u1000000) ;; Maximum energy reserve capacity (in kWh)

;; Define maps for user balances and energy listings
(define-map eco-token-balance principal uint) ;; Maps user principal to EcoToken balance
(define-map energy-listing {seller: principal} {amount: uint, price: uint}) ;; Energy listings for sale

;; Private functions

;; Calculate transaction fee
(define-private (calculate-transaction-fee (amount uint))
  (/ (* amount (var-get transaction-fee)) u100))

;; Calculate refund for energy purchases
(define-private (calculate-refund (amount uint))
  (/ (* amount (var-get eco-token-price) (var-get refund-percentage)) u100))

;; Private function to update energy reserve
(define-private (adjust-energy-reserve (amount int))
  (let (
    (current-reserve (var-get total-energy-reserve))
    (new-reserve (if (< amount 0)
                     (if (>= current-reserve (to-uint (- 0 amount)))
                         (- current-reserve (to-uint (- 0 amount)))
                         u0)
                     (+ current-reserve (to-uint amount))))
  )
    (asserts! (<= new-reserve (var-get energy-reserve-cap)) err-max-reserve-exceeded)
    (var-set total-energy-reserve new-reserve)
    (ok true)))

;; Public functions

;; Set EcoToken price (only contract admin)
(define-public (set-eco-token-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (> new-price u0) err-price-too-low)
    (var-set eco-token-price new-price)
    (ok true)))

;; Set transaction fee percentage (only contract admin)
(define-public (set-transaction-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (<= new-fee u100) err-fee-exceeds-limit)
    (var-set transaction-fee new-fee)
    (ok true)))
