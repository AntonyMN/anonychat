<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

class ResetDemoDatabase extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:reset-demo-database';
    protected $description = 'Resets the database for demo mode by truncating all chat-related data and re-seeding users.';

    public function handle()
    {
        if (config('app.env') !== 'demo') {
            $this->error('This command can only be run in demo mode.');
            return;
        }

        $this->info('Resetting demo database...');

        // Disable foreign key checks
        \Schema::disableForeignKeyConstraints();

        // Truncate tables
        \DB::table('messages')->truncate();
        \DB::table('conversations')->truncate();
        \DB::table('conversation_user')->truncate();
        \DB::table('friend_requests')->truncate();
        \DB::table('friends')->truncate();
        \DB::table('fcm_tokens')->truncate();
        \DB::table('message_attachments')->truncate();
        \DB::table('users')->truncate();

        \Schema::enableForeignKeyConstraints();

        // Re-seed
        $this->call('db:seed', ['--force' => true]);

        $this->info('Demo database reset successfully.');
    }
}
