<?php

namespace Database\Seeders;

use App\Models\News;
use App\Models\Team;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;
use Carbon\Carbon;

use Illuminate\Support\Facades\Schema;

class NewsSeeder extends Seeder
{
    public function run(): void
    {
        // Clear existing news to prevent duplicates
        Schema::disableForeignKeyConstraints();
        News::truncate();
        Schema::enableForeignKeyConstraints();

        $teams = Team::all();
        $authors = User::whereHas('roles', function ($query) {
            $query->where('name', 'admin');
        })->get();

        if ($authors->isEmpty()) {
            $authors = User::limit(3)->get();
        }

        $newsData = [
            [
                'title' => 'V.League 2024: Cuộc đua vô địch nóng bỏng - Nam Định bứt phá',
                'content' => "Cuộc đua đến ngôi vương V.League 2023/24 đang bước vào giai đoạn gay cấn nhất với sự tách tốp rõ rệt của Thép Xanh Nam Định. Đội bóng thành Nam đang thể hiện một phong độ hủy diệt và sự ổn định đáng kinh ngạc, điều mà họ đã thiếu ở những mùa giải trước.\n\n**Sức mạnh hủy diệt từ hàng công**\n\nVới chiến thắng thuyết phục 3-0 trước Becamex Bình Dương ngay tại sân Gò Đậu ở vòng đấu vừa qua, thầy trò HLV Vũ Hồng Việt đã nới rộng khoảng cách với nhóm bám đuổi lên thành 6 điểm. Sự tỏa sáng của Rafaelson và Hendrio tiếp tục là chìa khóa mở ra những chiến thắng cho Nam Định. Bộ đôi ngoại binh này đã đóng góp tới hơn 70% số bàn thắng của cả đội từ đầu mùa. Rafaelson, với cú đúp trong trận đấu này, đã nâng tổng số bàn thắng của mình lên con số 19, một hiệu suất ghi bàn khủng khiếp mà V.League chưa từng chứng kiến trong nhiều năm qua.\n\n**Sự sa sút của các đối thủ cạnh tranh**\n\nTrong khi đó, nhà đương kim vô địch Công An Hà Nội (CAHN) đang có dấu hiệu hụt hơi. Những trận hòa đáng tiếc trước các đối thủ yếu hơn như Quảng Nam hay Hà Tĩnh đã khiến họ đánh mất lợi thế trong cuộc đua song mã. HLV Kiatisuk vẫn đang loay hoay trong việc tìm ra công thức chiến thắng ổn định cho dàn sao của mình. Sự thiếu vắng những trụ cột nơi hàng thủ do chấn thương cũng là một nguyên nhân khiến CAHN không còn giữ được sự chắc chắn cần thiết.\n\n**Cơ hội nào cho nhóm bám đuổi?**\n\nỞ phía sau, Hà Nội FC và Bình Định vẫn đang âm thầm bám đuổi. Dù cơ hội vô địch không còn quá lớn, nhưng cuộc đua vào Top 3 vẫn rất khốc liệt. Hà Nội FC với sự trở lại của Văn Quyết và Hùng Dũng đang dần lấy lại hình ảnh của một ông lớn. Chiến thắng 2-1 trước TP.HCM ở vòng đấu này là minh chứng cho thấy bản lĩnh của đội bóng Thủ đô vẫn còn đó.\n\n**Dự đoán chặng đường còn lại**\n\nNhững vòng đấu tới hứa hẹn sẽ còn nhiều bất ngờ khi các đội bóng nhóm cuối bảng cũng đang vùng vẫy mạnh mẽ để trụ hạng, tạo nên những rào cản khó chịu cho các ứng viên vô địch. Tuy nhiên, với phong độ hiện tại, thật khó để cản bước Thép Xanh Nam Định trên con đường lần đầu tiên nâng cao chiếc cúp vô địch V.League sau gần 40 năm chờ đợi.",
                'category' => 'hot_news',
                'is_featured' => true,
                'thumbnail' => 'https://images.unsplash.com/photo-1522778119026-d647f0565c6a?w=800&q=80', // Soccer stadium
            ],
            [
                'title' => 'Quang Hải tỏa sáng rực rỡ, CAHN giành 3 điểm kịch tính phút bù giờ',
                'content' => "Tiền vệ Nguyễn Quang Hải một lần nữa chứng minh đẳng cấp ngôi sao của mình khi tỏa sáng đúng lúc, mang về chiến thắng quý hơn vàng cho CLB Công An Hà Nội (CAHN) trong trận tiếp đón Sông Lam Nghệ An tại vòng 15 V.League.\n\n**Thế trận giằng co và bế tắc**\n\nTrận đấu diễn ra với thế trận giằng co. SLNA với sức trẻ và lối chơi phòng ngự phản công khoa học đã gây ra vô vàn khó khăn cho đội chủ nhà. Các học trò của HLV Phan Như Thuật chủ động nhường thế trận và chờ đợi thời cơ. Thậm chí, đội khách còn có bàn thắng vươn lên dẫn trước ở phút 60 sau một pha phản công mẫu mực, người lập công là Olaha với một cú sút chéo góc quyết đoán.\n\n**Khoảnh khắc thiên tài của Quang Hải**\n\nTuy nhiên, bản lĩnh của nhà đương kim vô địch đã lên tiếng đúng lúc. Phút 75, từ một pha đá phạt trực tiếp ở cự ly khoảng 25m, Quang Hải vẽ nên một đường cong tuyệt đẹp, đưa bóng găm thẳng vào góc chữ A, gỡ hòa 1-1 cho CAHN. Bàn thắng đã giải tỏa tâm lý nặng nề cho các cầu thủ chủ nhà và khiến cầu trường Hàng Đẫy như nổ tung.\n\n**Kịch tính phút bù giờ**\n\nKịch tính được đẩy lên cao trào ở phút bù giờ thứ 4. Khi tất cả đã nghĩ về một kết quả hòa, Quang Hải lại xuất hiện trong vòng cấm, đón đường tạt bóng của Văn Thanh và tung cú vô lê quyết đoán bằng chân trái sở trường, ấn định chiến thắng 2-1 nghẹt thở. Đây là bàn thắng thứ 6 của Quang Hải ở mùa giải năm nay, giúp anh tiếp tục dẫn đầu danh sách vua phá lưới nội.\n\n**Phát biểu sau trận đấu**\n\n\"Đây là một chiến thắng khó khăn nhưng xứng đáng. Toàn đội đã không bỏ cuộc và chiến đấu đến những giây cuối cùng. Tôi xin dành tặng bàn thắng này cho người hâm mộ và gia đình, những người luôn ủng hộ tôi,\" Quang Hải chia sẻ sau trận đấu. Với 3 điểm có được, CAHN tiếp tục bám đuổi Nam Định trên bảng xếp hạng.",
                'category' => 'highlight',
                'is_featured' => true,
                'thumbnail' => 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&q=80', // Soccer player kicking
            ],
            [
                'title' => 'Tuyển Việt Nam công bố danh sách: Làn gió mới từ HLV Kim Sang-sik',
                'content' => "Tân HLV trưởng Kim Sang-sik vừa chính thức công bố danh sách 27 cầu thủ Đội tuyển Việt Nam chuẩn bị cho hai trận đấu còn lại tại Vòng loại thứ 2 World Cup 2026 khu vực châu Á gặp Philippines và Iraq. Đây là bản danh sách đầu tiên của chiến lược gia người Hàn Quốc kể từ khi nhậm chức, vì vậy nó nhận được sự quan tâm đặc biệt từ giới chuyên môn và người hâm mộ.\n\n**Sự trở lại của các cựu binh**\n\nBản danh sách lần này đánh dấu sự trở lại của nhiều cựu binh dày dạn kinh nghiệm như Đỗ Hùng Dũng, Nguyễn Hoàng Đức, Đặng Văn Lâm, Bùi Tiến Dũng... Đây là động thái cho thấy HLV Kim Sang-sik muốn ưu tiên sự ổn định và kinh nghiệm trong bối cảnh ĐT Việt Nam đang cần những kết quả tốt ngay lập tức. Sự vắng mặt của Quế Ngọc Hải cũng để lại nhiều tiếc nuối khi trung vệ này chưa hoàn toàn bình phục chấn thương.\n\n**Cơ hội cho những nhân tố mới**\n\nBên cạnh đó, chiến lược gia người Hàn Quốc cũng trao cơ hội cho một số gương mặt trẻ đang có phong độ cao tại V.League như thủ môn Quan Văn Chuẩn, tiền đạo Nguyễn Văn Tùng, tiền vệ Thái Sơn. Đặc biệt, sự xuất hiện của tiền đạo trẻ Bùi Vĩ Hào (Bình Dương) là một bất ngờ thú vị. Cầu thủ này đã có những màn trình diễn ấn tượng tại VCK U23 châu Á vừa qua.\n\n**Trường hợp của Công Phượng**\n\nĐáng chú ý, tiền đạo Nguyễn Công Phượng tiếp tục vắng mặt. Theo giải thích của VFF, Công Phượng gặp chấn thương nhẹ và chưa đạt thể trạng tốt nhất tại Yokohama FC. HLV Kim Sang-sik đã trực tiếp liên lạc và động viên Công Phượng, hẹn anh ở những đợt tập trung tiếp theo.\n\n**Mục tiêu và lộ trình**\n\n\"Mục tiêu của chúng tôi là giành chiến thắng trong cả hai trận đấu tới để nuôi hy vọng đi tiếp. Tôi tin tưởng vào năng lực và khát khao của các cầu thủ. Chúng tôi sẽ chơi một thứ bóng đá cống hiến và hiệu quả,\" HLV Kim Sang-sik phát biểu trong buổi họp báo. Đội tuyển Việt Nam dự kiến sẽ hội quân vào ngày 1/6 tại Hà Nội và có khoảng 5 ngày tập luyện trước khi tiếp đón Philippines trên sân Mỹ Đình vào ngày 6/6.",
                'category' => 'team_news',
                'is_featured' => false,
                'thumbnail' => 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=800&q=80', // Football team huddle
            ],
            [
                'title' => 'Thị trường chuyển nhượng V.League: Các CLB ráo riết săn "hàng khủng"',
                'content' => "Giai đoạn chuyển nhượng giữa mùa giải V.League 2023/24 đang diễn ra vô cùng sôi động. Các đội bóng đang chạy đua với thời gian để bổ sung lực lượng, đặc biệt là các suất ngoại binh, nhằm chuẩn bị cho giai đoạn nước rút.\n\n**Thể Công Viettel kích nổ bom tấn**\n\nCLB Thể Công Viettel vừa gây sốc khi công bố bản hợp đồng với tiền đạo người Brazil, Pedro Henrique. Chân sút 27 tuổi này từng có kinh nghiệm thi đấu tại giải VĐQG Bồ Đào Nha và được kỳ vọng sẽ giải quyết bài toán ghi bàn cho đội bóng áo lính. Mức lương của Pedro được đồn đoán lên tới 20.000 USD/tháng, biến anh trở thành một trong những ngoại binh hưởng lương cao nhất giải đấu.\n\n**Hà Nội FC gia cố hàng thủ**\n\nTrong khi đó, Hà Nội FC cũng không chịu kém cạnh khi chiêu mộ thành công trung vệ Tim Hall. Cầu thủ người Luxembourg sở hữu chiều cao 1m90 và từng khoác áo ĐTQG nước này. Đây được xem là sự bổ sung chất lượng cho hàng thủ đang gặp nhiều vấn đề của đội bóng Thủ đô sau sự ra đi của Bùi Hoàng Việt Anh.\n\n**Cuộc chạy đua của nhóm cuối bảng**\n\nỞ nhóm cuối bảng, HAGL và Khánh Hòa cũng đang tích cực thử việc các ngoại binh. HAGL vừa mượn thành công thủ môn Bùi Tiến Dũng và tiền vệ Huỳnh Tấn Tài từ CAHN, đồng thời đang nhắm đến một tiền đạo ngoại chất lượng để chia lửa với Jhon Cley. Khánh Hòa, với nguồn kinh phí hạn hẹp, đang tìm kiếm những bản hợp đồng giá rẻ từ các giải hạng dưới của Brazil.\n\n**Dự báo những ngày cuối**\n\nThị trường chuyển nhượng sẽ đóng cửa vào ngày 18/3, hứa hẹn sẽ còn nhiều thương vụ \"bom tấn\" được kích hoạt vào phút chót. Các CLB như Bình Dương, Thanh Hóa cũng đang rục rịch thay thế ngoại binh để tăng cường sức mạnh cho cuộc đua vô địch.",
                'category' => 'transfer',
                'is_featured' => true,
                'thumbnail' => 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&q=80', // Tactics board
            ],
            [
                'title' => 'Phỏng vấn độc quyền: Đình Bắc - "Tôi muốn được nhớ đến bằng những bàn thắng"',
                'content' => "Nguyễn Đình Bắc, sao mai 19 tuổi của bóng đá Việt Nam, đang trải qua những ngày tháng thăng trầm trong sự nghiệp. Sau những màn trình diễn ấn tượng tại Asian Cup 2023, anh đã gặp phải một số rắc rối bên lề sân cỏ. Trong buổi phỏng vấn độc quyền với SportLife, Đình Bắc đã có những chia sẻ thẳng thắn về quãng thời gian vừa qua.\n\n**PV: Chào Đình Bắc, cảm giác của bạn thế nào sau khi trở lại thi đấu sau án phạt nội bộ?**\n\n**Đình Bắc:** Đó là một khoảng thời gian thực sự khó khăn với tôi. Tôi đã suy nghĩ rất nhiều về những gì đã qua. Tôi nhận ra mình còn trẻ và cần phải học hỏi, trưởng thành hơn rất nhiều. Tôi biết mình đã làm sai và tôi chấp nhận mọi hình phạt. Được trở lại sân cỏ là niềm hạnh phúc lớn nhất, tôi muốn chuộc lỗi bằng những màn trình diễn trên sân.\n\n**PV: Bạn đã học được gì sau sự cố vừa rồi?**\n\n**Đình Bắc:** Tôi học được bài học về sự chuyên nghiệp và kỷ luật. Tài năng thôi là chưa đủ, thái độ tập luyện và sinh hoạt mới là điều quyết định sự thành công của một cầu thủ. Tôi biết ơn HLV Văn Sỹ Sơn và ban lãnh đạo CLB Quảng Nam đã cho tôi cơ hội sửa sai.\n\n**PV: Mục tiêu của bạn trong thời gian tới là gì?**\n\n**Đình Bắc:** Trước mắt, tôi muốn tập trung thi đấu thật tốt cho CLB Quảng Nam, giúp đội bóng trụ hạng thành công. Xa hơn nữa, tôi khao khát được HLV Kim Sang-sik triệu tập lên ĐTQG. Tôi muốn được cống hiến và được người hâm mộ nhớ đến bằng những bàn thắng, những pha bóng đẹp chứ không phải những ồn ào ngoài chuyên môn. Giấc mơ của tôi vẫn là được ra nước ngoài thi đấu, nhưng tôi biết mình cần phải nỗ lực hơn nữa.\n\n**PV: Bạn có thần tượng cầu thủ nào không?**\n\n**Đình Bắc:** Tôi rất hâm mộ anh Son Heung-min. Sự chuyên nghiệp và nỗ lực không ngừng nghỉ của anh ấy là tấm gương để tôi noi theo. Tôi cũng thường xuyên xem lại các video thi đấu của anh ấy để học hỏi cách di chuyển và dứt điểm.\n\n**PV: Cảm ơn Đình Bắc và chúc bạn sẽ gặt hái được nhiều thành công!**",
                'category' => 'interview',
                'is_featured' => false,
                'thumbnail' => 'https://images.unsplash.com/photo-1590324453404-10344ee7d9f2?w=800&q=80', // Interview microphone
            ],
            [
                'title' => 'Kết quả vòng 18: Bất ngờ tại Hàng Đẫy, Thể Công Viettel ngã ngựa',
                'content' => "Vòng 18 V.League chứng kiến cú sốc lớn tại sân Hàng Đẫy khi Thể Công Viettel bất ngờ nhận thất bại 0-1 trước đội khách LPBank HAGL. Đây là kết quả ít ai ngờ tới trước giờ bóng lăn khi Viettel được đánh giá cao hơn hẳn về lực lượng và phong độ, lại được thi đấu trên sân nhà.\n\n**Viettel bế tắc toàn tập**\n\nNhập cuộc tự tin, Thể Công Viettel dồn ép đối thủ ngay từ những phút đầu. Hoàng Đức và các đồng đội kiểm soát bóng tới 65%, tạo ra hàng tá cơ hội ngon ăn. Tuy nhiên, sự vô duyên của các chân sút cùng sự xuất sắc của thủ môn Bùi Tiến Dũng bên phía HAGL đã từ chối tất cả. Hàng phòng ngự số đông của HAGL đã chơi một trận đấu quả cảm, lăn xả để bảo vệ khung thành.\n\n**Đòn hồi mã thương của HAGL**\n\nTấn công nhiều không ghi được bàn thắng, đội chủ nhà đã phải trả giá. Phút 68, từ một pha phản công nhanh, Châu Ngọc Quang có đường chọc khe tinh tế để Joao Veras thoát xuống dứt điểm chéo góc, hạ gục thủ môn Văn Phong, mở tỉ số trận đấu. Đây là pha bóng cho thấy sự thực dụng đáng sợ mà HLV Vũ Tiến Thành đang xây dựng cho HAGL.\n\n**Nỗ lực bất thành**\n\nNhững phút còn lại, Viettel dốc toàn lực tấn công, tung cả những quân bài dự bị chiến lược vào sân nhưng bất lực trước hàng phòng ngự kỷ luật của đội bóng phố Núi. Thất bại này khiến Thể Công Viettel dậm chân ở giữa bảng xếp hạng, trong khi 3 điểm quý giá giúp HAGL tạm thời thoát khỏi nhóm cầm đèn đỏ, thắp lên hy vọng trụ hạng.\n\n**Kết quả các trận đấu khác**\n\nỞ các trận đấu khác, Bình Dương thắng Khánh Hòa 3-1 để tiếp tục bám đuổi Nam Định, trong khi Hải Phòng chia điểm với Thanh Hóa trong trận cầu không bàn thắng đầy tẻ nhạt.",
                'category' => 'highlight',
                'is_featured' => false,
                'thumbnail' => 'https://images.unsplash.com/photo-1624880357913-a8539238245b?w=800&q=80', // Football match action
            ],
            [
                'title' => 'Phân tích chiến thuật: Tại sao HAGL hồi sinh dưới thời HLV Vũ Tiến Thành?',
                'content' => "Kể từ khi HLV Vũ Tiến Thành lên nắm quyền, CLB HAGL đã có sự lột xác ngoạn mục. Từ một đội bóng rệu rã, thiếu sức sống, đội bóng phố Núi đã trở thành một tập thể lì lợm, khó bị đánh bại. Chuỗi 5 trận bất bại liên tiếp là minh chứng rõ nét nhất cho sự hồi sinh này.\n\n**Phòng ngự chặt chẽ là ưu tiên hàng đầu**\n\nKhác với triết lý bóng đá đẹp nhưng mong manh trước đây dưới thời Kiatisuk, HLV Vũ Tiến Thành xây dựng HAGL dựa trên nền tảng hàng phòng ngự vững chắc. Ông yêu cầu các cầu thủ tuân thủ kỷ luật chiến thuật, bọc lót cho nhau tốt và không ngại va chạm. Sơ đồ 5-4-1 được vận hành trơn tru, biến khung thành của Bùi Tiến Dũng trở thành một pháo đài khó xâm phạm. Nhờ đó, số bàn thua của HAGL đã giảm đáng kể trong những vòng đấu gần đây.\n\n**Tận dụng tối đa các tình huống cố định**\n\nBiết mình không có nhiều ngôi sao tấn công xuất sắc, HAGL chú trọng vào các tình huống cố định. Những pha đá phạt góc, đá phạt trực tiếp được họ dàn xếp bài bản và trở thành vũ khí lợi hại để tìm kiếm bàn thắng. Sự xuất hiện của các ngoại binh có chiều cao tốt như Jairo hay Gabriel Dias giúp HAGL luôn nguy hiểm trong các pha không chiến.\n\n**Tinh thần chiến đấu rực lửa**\n\nĐiều quan trọng nhất mà HLV Vũ Tiến Thành mang lại cho HAGL chính là tinh thần chiến đấu. Các cầu thủ ra sân với sự quyết tâm cao độ, chạy không biết mệt mỏi và chiến đấu vì màu cờ sắc áo. Ông Thành đã truyền được ngọn lửa nhiệt huyết, khơi dậy lòng tự trọng của các cầu thủ trẻ. Chính tinh thần này đã giúp họ vượt qua những thời điểm khó khăn nhất, như trận thắng ngược dòng trước Thanh Hóa hay trận hòa quả cảm trước CAHN.",
                'category' => 'team_news',
                'is_featured' => false,
                'thumbnail' => 'https://images.unsplash.com/photo-1553778263-73a83bab9b0c?w=800&q=80', // Tactics/Analysis
            ],
            [
                'title' => 'Tin đồn: CLB CAHN nhắm đến ngôi sao Thái Lan Theerathon Bunmathan',
                'content' => "Theo nhiều nguồn tin uy tín từ Thái Lan, CLB Công An Hà Nội (CAHN) đang lên kế hoạch chiêu mộ hậu vệ trái số 1 Đông Nam Á hiện nay - Theerathon Bunmathan. Đội bóng ngành Công an được cho là sẵn sàng chi ra một mức lương kỷ lục để thuyết phục ngôi sao người Thái Lan sang V.League thi đấu.\n\n**Tham vọng hóa rồng của CAHN**\n\nSau khi chiêu mộ thành công Quang Hải, Văn Hậu, Filip Nguyễn, CAHN vẫn chưa muốn dừng lại. Họ muốn biến mình thành một \"PSG của Việt Nam\" với dàn sao thượng hạng. Theerathon Bunmathan được xem là mảnh ghép hoàn hảo để nâng tầm đẳng cấp của đội bóng, không chỉ ở V.League mà còn ở đấu trường châu lục mùa giải tới.\n\n**Đẳng cấp của Theerathon**\n\nTheerathon Bunmathan hiện đang khoác áo Buriram United và là trụ cột không thể thay thế của ĐTQG Thái Lan. Anh sở hữu cái chân trái cực khéo, khả năng tạt bóng chuẩn xác và những cú sút xa uy lực. Kinh nghiệm thi đấu tại J.League trong màu áo Yokohama F. Marinos (nơi anh từng vô địch Nhật Bản) là điều mà không cầu thủ Đông Nam Á nào sánh kịp.\n\n**Những rào cản**\n\nTuy nhiên, CAHN sẽ phải cạnh tranh gay gắt với nhiều đội bóng lớn khác trong khu vực cũng đang khao khát có được chữ ký của Theerathon. Mức lương của anh tại Buriram hiện tại đã rất cao (khoảng 50.000 USD/tháng). Ngoài ra, việc thuyết phục Buriram United nhả người cũng không phải là điều dễ dàng khi họ đang hướng tới mục tiêu vô địch Thai League và tiến sâu tại AFC Champions League. Hợp đồng của Theerathon với Buriram còn thời hạn đến năm 2025, vì vậy mức phí chuyển nhượng chắc chắn sẽ không hề rẻ.",
                'category' => 'transfer',
                'is_featured' => true,
                'thumbnail' => 'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?w=800&q=80', // Football contract/transfer
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
                'thumbnail' => $data['thumbnail'] ?? 'news/placeholder.jpg',
            ]);
        }
    }
}
