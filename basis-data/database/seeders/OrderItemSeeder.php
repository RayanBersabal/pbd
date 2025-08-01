<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;

class OrderItemSeeder extends Seeder
{
    public function run(): void
    {
        // Ambil semua order yang sudah dibuat
        $orders = Order::all();

        foreach ($orders as $order) {
            // Untuk setiap order, buat 1 hingga 3 item pesanan
            $numItems = rand(1, 3);
            for ($i = 0; $i < $numItems; $i++) {
                $product = Product::inRandomOrder()->first();
                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'product_name' => $product->name,
                    'price' => $product->price,
                    'quantity' => rand(1, 5),
                ]);
            }
        }
    }
}
