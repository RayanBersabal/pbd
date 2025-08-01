<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class OrderFactory extends Factory
{

    protected $model = Order::class;

    public function definition(): array
    {
        $paymentStatus = fake()->randomElement(['pending', 'paid', 'failed']);
        $status = fake()->randomElement(['Dipesan', 'Disiapkan', 'Dikirim', 'Pesanan Selesai']);
        $subtotal = fake()->numberBetween(10000, 300000);
        $deliveryFee = fake()->numberBetween(5000, 20000);
        $adminFee = 5000;
        $totalAmount = $subtotal + $deliveryFee + $adminFee;

        return [
            'user_id' => User::inRandomOrder()->first()->id,
            'customer_name' => fake()->name(),
            'customer_phone' => fake()->phoneNumber(),
            'delivery_address' => fake()->address(),
            'notes' => fake()->sentence(),
            'payment_type' => fake()->randomElement(['tunai', 'qris', 'transfer bank']),
            'subtotal' => $subtotal,
            'delivery_fee' => $deliveryFee,
            'admin_fee' => $adminFee,
            'total_amount' => $totalAmount,
            'payment_status' => $paymentStatus,
            'payment_reference' => ($paymentStatus == 'paid') ? 'REF-' . fake()->randomNumber(8) : null,
            'paid_at' => ($paymentStatus == 'paid') ? now() : null,
            'status' => $status,
            'estimated_delivery_time' => '30-45 menit',
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }
}
