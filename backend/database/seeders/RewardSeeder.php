<?php

namespace Database\Seeders;

use App\Models\Reward;
use App\Models\Sponsor;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RewardSeeder extends Seeder
{
    public function run(): void
    {
        // Disable foreign key checks to allow truncate
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        Reward::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        $nikeSponsor = Sponsor::where('company_name', 'Nike Vietnam')->first();
        $pepsiSponsor = Sponsor::where('company_name', 'Pepsi Vietnam')->first();
        $sportlifeSponsor = Sponsor::where('company_name', 'SportLife Premium')->first();

        $rewards = [
            // =====================
            // VOUCHER - Mã giảm giá
            // =====================
            [
                'name' => 'Voucher Pepsi 50K',
                'description' => 'Voucher trị giá 50.000đ áp dụng cho các sản phẩm Pepsi tại cửa hàng tiện lợi toàn quốc. Hạn sử dụng 30 ngày kể từ ngày đổi.',
                'type' => 'voucher',
                'image' => 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?auto=format&fit=crop&w=800&q=80',
                'points_required' => 300,
                'stock' => 500,
                'sponsor_id' => $pepsiSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Voucher Pepsi 100K',
                'description' => 'Voucher trị giá 100.000đ áp dụng cho các sản phẩm Pepsi tại cửa hàng tiện lợi toàn quốc. Hạn sử dụng 30 ngày kể từ ngày đổi.',
                'type' => 'voucher',
                'image' => 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=800&q=80',
                'points_required' => 550,
                'stock' => 300,
                'sponsor_id' => $pepsiSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Voucher Nike 200K',
                'description' => 'Voucher trị giá 200.000đ áp dụng khi mua sản phẩm Nike tại các cửa hàng chính hãng. Không áp dụng cùng chương trình khuyến mãi khác.',
                'type' => 'voucher',
                'image' => 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
                'points_required' => 1500,
                'stock' => 150,
                'sponsor_id' => $nikeSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Voucher Nike 500K',
                'description' => 'Voucher trị giá 500.000đ áp dụng khi mua sản phẩm Nike tại các cửa hàng chính hãng. Không áp dụng cùng chương trình khuyến mãi khác.',
                'type' => 'voucher',
                'image' => 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?auto=format&fit=crop&w=800&q=80',
                'points_required' => 3500,
                'stock' => 80,
                'sponsor_id' => $nikeSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Voucher Grab 100K',
                'description' => 'Mã giảm giá 100.000đ cho dịch vụ GrabFood hoặc GrabCar. Áp dụng cho đơn hàng từ 150.000đ.',
                'type' => 'voucher',
                'image' => 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
                'points_required' => 800,
                'stock' => 200,
                'sponsor_id' => null,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(3),
            ],
            [
                'name' => 'Voucher Shopee 150K',
                'description' => 'Mã giảm giá 150.000đ cho đơn hàng Shopee từ 500.000đ. Áp dụng cho tất cả sản phẩm.',
                'type' => 'voucher',
                'image' => 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=800&q=80',
                'points_required' => 1200,
                'stock' => 100,
                'sponsor_id' => null,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(3),
            ],

            // =====================
            // PHYSICAL - Quà vật lý
            // =====================
            [
                'name' => 'Áo thun SportLife',
                'description' => 'Áo thun chính hãng SportLife, chất liệu cotton cao cấp, thoáng mát. Có nhiều size từ S đến XXL.',
                'type' => 'physical',
                'image' => 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
                'points_required' => 2000,
                'stock' => 200,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Mũ lưỡi trai SportLife',
                'description' => 'Mũ lưỡi trai thể thao phong cách, thêu logo SportLife. Phù hợp cho các hoạt động ngoài trời.',
                'type' => 'physical',
                'image' => 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?auto=format&fit=crop&w=800&q=80',
                'points_required' => 1000,
                'stock' => 300,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Bóng đá Nike Flight',
                'description' => 'Bóng đá Nike Flight chính hãng size 5, được sử dụng trong các giải đấu chuyên nghiệp.',
                'type' => 'physical',
                'image' => 'https://images.unsplash.com/photo-1614632537190-23e4146777db?auto=format&fit=crop&w=800&q=80',
                'points_required' => 5000,
                'stock' => 50,
                'sponsor_id' => $nikeSponsor?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Áo đấu Nike - CLB yêu thích',
                'description' => 'Áo đấu chính hãng Nike của CLB bạn yêu thích (Manchester United, Barcelona, Chelsea...). Có đầy đủ size.',
                'type' => 'physical',
                'image' => 'https://images.unsplash.com/photo-1577212017184-80cc0da11082?auto=format&fit=crop&w=800&q=80',
                'points_required' => 10000,
                'stock' => 30,
                'sponsor_id' => $nikeSponsor?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Giày Nike Air Max',
                'description' => 'Giày thể thao Nike Air Max phiên bản giới hạn. Thiết kế hiện đại, đệm khí êm ái.',
                'type' => 'physical',
                'image' => 'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=800&q=80',
                'points_required' => 25000,
                'stock' => 10,
                'sponsor_id' => $nikeSponsor?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Balo thể thao Nike',
                'description' => 'Balo thể thao Nike Brasilia, dung tích 24L, chống thấm nước, nhiều ngăn tiện dụng.',
                'type' => 'physical',
                'image' => 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80',
                'points_required' => 4500,
                'stock' => 40,
                'sponsor_id' => $nikeSponsor?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Bình nước thể thao',
                'description' => 'Bình nước thể thao SportLife 750ml, giữ nhiệt tốt, an toàn BPA-free.',
                'type' => 'physical',
                'image' => 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
                'points_required' => 600,
                'stock' => 500,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],

            // =====================
            // VIRTUAL - Gói đăng ký số
            // =====================
            [
                'name' => 'SportLife Premium 1 Tháng',
                'description' => 'Trải nghiệm SportLife Premium trong 1 tháng: không quảng cáo, xem trực tiếp HD, thống kê chi tiết và nhiều tính năng độc quyền.',
                'type' => 'virtual',
                'image' => 'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?auto=format&fit=crop&w=800&q=80',
                'points_required' => 500,
                'stock' => 9999,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'SportLife Premium 3 Tháng',
                'description' => 'Trải nghiệm SportLife Premium trong 3 tháng với mức giá tiết kiệm hơn 20%. Bao gồm tất cả tính năng Premium.',
                'type' => 'virtual',
                'image' => 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&w=800&q=80',
                'points_required' => 1200,
                'stock' => 9999,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'SportLife Premium 1 Năm',
                'description' => 'Gói Premium 1 năm - tiết kiệm đến 40%. Tận hưởng trọn vẹn mùa giải với tất cả tính năng cao cấp nhất.',
                'type' => 'virtual',
                'image' => 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?auto=format&fit=crop&w=800&q=80',
                'points_required' => 4000,
                'stock' => 9999,
                'sponsor_id' => $sportlifeSponsor?->id,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
            [
                'name' => 'Spotify Premium 1 Tháng',
                'description' => 'Mã kích hoạt Spotify Premium 1 tháng - nghe nhạc không quảng cáo, tải offline, chất lượng cao.',
                'type' => 'virtual',
                'image' => 'https://images.unsplash.com/photo-1614680376593-902f74cf0d41?auto=format&fit=crop&w=800&q=80',
                'points_required' => 700,
                'stock' => 200,
                'sponsor_id' => null,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Netflix Standard 1 Tháng',
                'description' => 'Mã kích hoạt Netflix gói Standard 1 tháng - xem phim Full HD trên 2 thiết bị cùng lúc.',
                'type' => 'virtual',
                'image' => 'https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85?auto=format&fit=crop&w=800&q=80',
                'points_required' => 1500,
                'stock' => 100,
                'sponsor_id' => null,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],

            // =====================
            // TICKET - Vé sự kiện
            // =====================
            [
                'name' => 'Vé xem V.League',
                'description' => 'Vé xem trực tiếp trận đấu V.League tại sân vận động. Bạn có thể chọn trận đấu và khu vực ngồi khi đổi thưởng.',
                'type' => 'ticket',
                'image' => 'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&w=800&q=80',
                'points_required' => 3000,
                'stock' => 100,
                'sponsor_id' => null,
                'is_active' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Vé VIP V.League',
                'description' => 'Vé VIP xem trận đấu V.League với ghế ngồi cao cấp, bao gồm đồ ăn nhẹ và nước uống.',
                'type' => 'ticket',
                'image' => 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=800&q=80',
                'points_required' => 8000,
                'stock' => 30,
                'sponsor_id' => null,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Vé Fan Meeting cầu thủ',
                'description' => 'Cơ hội gặp gỡ và giao lưu với các cầu thủ yêu thích. Bao gồm chụp ảnh và xin chữ ký.',
                'type' => 'ticket',
                'image' => 'https://images.unsplash.com/photo-1459865264687-595d652de67e?auto=format&fit=crop&w=800&q=80',
                'points_required' => 15000,
                'stock' => 20,
                'sponsor_id' => null,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Tour tham quan sân vận động',
                'description' => 'Tour tham quan sân vận động quốc gia Mỹ Đình, bao gồm khu vực phòng thay đồ và sân cỏ.',
                'type' => 'ticket',
                'image' => 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?auto=format&fit=crop&w=800&q=80',
                'points_required' => 5000,
                'stock' => 50,
                'sponsor_id' => null,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addMonths(6),
            ],
            [
                'name' => 'Vé xem World Cup 2026',
                'description' => 'Cơ hội sở hữu vé xem World Cup 2026 tại Mỹ, Canada hoặc Mexico. Quà tặng cực kỳ giới hạn!',
                'type' => 'ticket',
                'image' => 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=800&q=80',
                'points_required' => 100000,
                'stock' => 5,
                'sponsor_id' => null,
                'is_active' => true,
                'is_physical' => true,
                'expiry_date' => Carbon::now()->addYear(),
            ],
        ];

        foreach ($rewards as $reward) {
            Reward::create($reward);
        }
    }
}
