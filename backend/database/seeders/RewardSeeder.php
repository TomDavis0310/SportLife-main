<?php

namespace Database\Seeders;

use App\Models\Reward;
use App\Models\Sponsor;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class RewardSeeder extends Seeder
{
    public function run(): void
    {
        $nikeSponsore = Sponsor::where('company_name', 'Nike Vietnam')->first();
        $pepsiSponsor = Sponsor::where('company_name', 'Pepsi Vietnam')->first();
        $sportlifeSponsor = Sponsor::where('company_name', 'SportLife Premium')->first();

        $rewards = [
            // Digital Rewards
            [
                'name' => 'SportLife Premium 1 Month',
                'description' => 'Get 1 month of SportLife Premium with ad-free experience and exclusive features',
                'type' => 'virtual',
                'image' => 'rewards/premium-1month.png',
                'points_required' => 500,
                'stock' => 1000,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'SportLife Premium 3 Months',
                'description' => 'Get 3 months of SportLife Premium with ad-free experience and exclusive features',
                'type' => 'virtual',
                'image' => 'rewards/premium-3months.png',
                'points_required' => 1200,
                'stock' => 500,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],

            // Vouchers
            [
                'name' => 'Pepsi Voucher 50K',
                'description' => 'Voucher 50,000 VND for Pepsi products at any convenience store',
                'type' => 'voucher',
                'image' => 'rewards/pepsi-50k.png',
                'points_required' => 300,
                'stock' => 200,
                'sponsor_id' => $pepsiSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(3),
            ],
            [
                'name' => 'Nike Voucher 200K',
                'description' => 'Voucher 200,000 VND for Nike products at official stores',
                'type' => 'voucher',
                'image' => 'rewards/nike-200k.png',
                'points_required' => 1500,
                'stock' => 100,
                'sponsor_id' => $nikeSponsore?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Nike Voucher 500K',
                'description' => 'Voucher 500,000 VND for Nike products at official stores',
                'type' => 'voucher',
                'image' => 'rewards/nike-500k.png',
                'points_required' => 3500,
                'stock' => 50,
                'sponsor_id' => $nikeSponsore?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],

            // Physical Merchandise
            [
                'name' => 'SportLife T-Shirt',
                'description' => 'Official SportLife branded T-shirt (cotton, various sizes)',
                'type' => 'physical',
                'image' => 'rewards/sportlife-tshirt.png',
                'points_required' => 2000,
                'stock' => 100,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Nike Football',
                'description' => 'Official Nike football - Size 5',
                'type' => 'physical',
                'image' => 'rewards/nike-football.png',
                'points_required' => 5000,
                'stock' => 30,
                'sponsor_id' => $nikeSponsore?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Nike Jersey - Team of Choice',
                'description' => 'Official Nike jersey for your favorite team',
                'type' => 'physical',
                'image' => 'rewards/nike-jersey.png',
                'points_required' => 10000,
                'stock' => 20,
                'sponsor_id' => $nikeSponsore?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],

            // Experiences
            [
                'name' => 'Match Day Ticket',
                'description' => 'Free ticket to a V.League match of your choice',
                'type' => 'ticket',
                'image' => 'rewards/match-ticket.png',
                'points_required' => 3000,
                'stock' => 50,
                'sponsor_id' => null,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'VIP Match Experience',
                'description' => 'VIP box ticket with food & drinks at a V.League match',
                'type' => 'ticket',
                'image' => 'rewards/vip-experience.png',
                'points_required' => 15000,
                'stock' => 10,
                'sponsor_id' => null,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
        ];

        foreach ($rewards as $reward) {
            Reward::create($reward);
        }
    }
}
