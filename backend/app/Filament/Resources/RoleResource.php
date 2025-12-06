<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RoleResource\Pages;
use Spatie\Permission\Models\Role;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Support\Enums\FontWeight;

class RoleResource extends Resource
{
    protected static ?string $model = Role::class;

    protected static ?string $navigationIcon = 'heroicon-o-shield-check';

    protected static ?string $navigationGroup = 'Người dùng';

    protected static ?string $modelLabel = 'Vai trò';

    protected static ?string $pluralModelLabel = 'Vai trò';

    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Thông tin vai trò')
                    ->description('Quản lý vai trò và quyền hạn trong hệ thống')
                    ->icon('heroicon-o-shield-check')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Tên vai trò')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255)
                            ->placeholder('Nhập tên vai trò (ví dụ: admin, manager)')
                            ->helperText('Tên vai trò phải là duy nhất trong hệ thống'),
                        Forms\Components\Select::make('guard_name')
                            ->label('Guard')
                            ->options([
                                'web' => 'Web (Mặc định)',
                                'api' => 'API',
                            ])
                            ->default('web')
                            ->required(),
                        Forms\Components\Textarea::make('description')
                            ->label('Mô tả')
                            ->maxLength(500)
                            ->placeholder('Mô tả ngắn về vai trò này...')
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Quyền hạn')
                    ->description('Chọn các quyền cho vai trò này')
                    ->icon('heroicon-o-key')
                    ->schema([
                        Forms\Components\CheckboxList::make('permissions')
                            ->label('Danh sách quyền')
                            ->relationship('permissions', 'name')
                            ->columns(3)
                            ->gridDirection('row')
                            ->searchable()
                            ->bulkToggleable(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Tên vai trò')
                    ->searchable()
                    ->sortable()
                    ->weight(FontWeight::Bold)
                    ->icon('heroicon-o-shield-check')
                    ->color(fn (string $state): string => match ($state) {
                        'admin' => 'danger',
                        'club_manager' => 'warning',
                        'sponsor' => 'info',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('guard_name')
                    ->label('Guard')
                    ->badge()
                    ->color('gray'),
                Tables\Columns\TextColumn::make('permissions_count')
                    ->label('Số quyền')
                    ->counts('permissions')
                    ->badge()
                    ->color('primary'),
                Tables\Columns\TextColumn::make('users_count')
                    ->label('Số người dùng')
                    ->counts('users')
                    ->badge()
                    ->color('success'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Ngày tạo')
                    ->dateTime('d/m/Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('guard_name')
                    ->label('Guard')
                    ->options([
                        'web' => 'Web',
                        'api' => 'API',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('Xem'),
                Tables\Actions\EditAction::make()
                    ->label('Sửa'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->label('Xóa đã chọn'),
                ]),
            ])
            ->striped();
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRoles::route('/'),
            'create' => Pages\CreateRole::route('/create'),
            'edit' => Pages\EditRole::route('/{record}/edit'),
        ];
    }
}
