#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#define AUDIT_SCRIPT "./scripts/cis_1_1_1_11.sh"

void run_audit(const char *script)
{
    pid_t pid = fork();

    if (pid < 0)
    {
        perror("fork");
        return;
    }

    if (pid == 0)
    {
        execl("/bin/bash", "bash", script, (char *)NULL);

        perror("execl");
        exit(EXIT_FAILURE);
    }

    int status;

    if (waitpid(pid, &status, 0) == -1)
    {
        perror("waitpid");
        return;
    }

    if (WIFEXITED(status))
    {
        printf("\nAudit exited with status: %d\n",
               WEXITSTATUS(status));
    }
    else
    {
        printf("\nAudit did not exit normally.\n");
    }
}

void show_menu(void)
{
    printf("\n");
    printf("========================================\n");
    printf("           CIS_CARACAL\n");
    printf("      Debian 13 Security Auditor\n");
    printf("========================================\n");
    printf("\n");

    printf("1. CIS 1.1.1.11 - Unused filesystem\n");
    printf("   kernel modules\n");

    printf("0. Exit\n");

    printf("\nSelect an option: ");
}

int main(void)
{
    int choice;

    while (1)
    {
        show_menu();

        if (scanf("%d", &choice) != 1)
        {
            printf("\nInvalid input. Please enter a number.\n");

            while (getchar() != '\n')
            {
                /* Clear invalid input */
            }

            continue;
        }

        switch (choice)
        {
            case 1:
                printf("\nRunning CIS 1.1.1.11 audit...\n\n");
                run_audit(AUDIT_SCRIPT);
                break;

            case 0:
                printf("\nExiting CIS_CARACAL.\n");
                return 0;

            default:
                printf("\nInvalid option.\n");
                break;
        }
    }

    return 0;
}