import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private readonly logger = new Logger(SupabaseService.name);
  private clientInstance?: SupabaseClient;

  constructor(private readonly configService: ConfigService) {}

  getClient(): SupabaseClient | undefined {
    if (this.clientInstance) {
      return this.clientInstance;
    }

    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      this.logger.warn(
        'Supabase URL or Key is missing. Supabase client will not be initialized.',
      );
      return undefined;
    }

    this.clientInstance = createClient(supabaseUrl, supabaseKey);
    this.logger.log('Supabase client initialized');
    return this.clientInstance;
  }
}
