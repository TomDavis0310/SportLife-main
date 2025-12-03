<?php

namespace Database\Seeders;

use App\Models\News;
use App\Models\Team;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;
use Carbon\Carbon;

class NewsSeeder extends Seeder
{
    public function run(): void
    {
        $teams = Team::all();
        $authors = User::whereHas('roles', function ($query) {
            $query->where('name', 'admin');
        })->get();

        if ($authors->isEmpty()) {
            $authors = User::limit(3)->get();
        }

        $newsData = [
            [
                'title' => 'Hà Nội FC chiêu mộ thành công tiền đạo tuyển Việt Nam',
                'content' => 'Hà Nội FC vừa chính thức công bố hợp đồng với tiền đạo số 1 của tuyển Việt Nam. Đây được xem là bản hợp đồng bom tấn nhất mùa chuyển nhượng này.',
                'category' => 'transfer',
                'is_featured' => true,
            ],
            [
                'title' => 'Hoàng Anh Gia Lai thắng đậm 4-0 trên sân nhà',
                'content' => 'Trong trận đấu vòng 15 V.League, Hoàng Anh Gia Lai đã có chiến thắng thuyết phục 4-0 trước đội khách. Công Phượng ghi hat-trick.',
                'category' => 'highlight',
                'is_featured' => true,
            ],
            [
                'title' => 'U23 Việt Nam hòa U23 Thái Lan 1-1',
                'content' => 'Trong trận giao hữu quốc tế, U23 Việt Nam đã có trận hòa đáng tiếc 1-1 trước U23 Thái Lan.',
                'category' => 'team_news',
                'is_featured' => false,
            ],
            [
                'title' => 'Văn Lâm giữ sạch lưới 5 trận liên tiếp',
                'content' => 'Thủ môn Đặng Văn Lâm đang có phong độ cao với 5 trận giữ sạch lưới liên tiếp.',
                'category' => 'hot_news',
                'is_featured' => true,
            ],
            [
                'title' => 'HLV Park Hang-seo chia tay tuyển Việt Nam',
                'content' => 'Sau 5 năm gắn bó đầy thành công, HLV Park Hang-seo chính thức chia tay tuyển Việt Nam.',
                'category' => 'interview',
                'is_featured' => false,
            ],
        ];

        foreach ($newsData as $index => $data) {
            $slugBase = Str::slug($data['title']);
            $slug = $slugBase;
            $counter = 1;

            while (News::where('slug', $slug)->exists()) {
                $slug = $slugBase . '-' . $counter;
                $counter++;
            }

            News::create([
                'title' => $data['title'],
                'slug' => $slug,
                'content' => $data['content'],
                'category' => $data['category'],
                'is_featured' => $data['is_featured'],
                'is_published' => true,
                'author_id' => $authors->random()->id,
                'team_id' => $teams->random()->id ?? null,
                'published_at' => Carbon::now()->subDays(rand(0, 30)),
                'views_count' => rand(100, 5000),
                'thumbnail' => 'news/placeholder.jpg',
            ]);
        }
    }
}
